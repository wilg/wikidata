# frozen_string_literal: true

module Wikidata
  class RestClient
    DEFAULT_REST_URL = "https://www.wikidata.org/w/rest.php/wikibase/v1"

    # Fetch a single item by ID using the REST API with conditional caching.
    # Returns [entity_hash, etag] or nil if 304 (not modified).
    def self.fetch_item(item_id, etag: nil)
      url = "#{base_url}/entities/items/#{item_id}"
      headers = {"Accept" => "application/json"}
      headers["If-None-Match"] = etag if etag

      response = client.get(url) do |req|
        headers.each { |k, v| req.headers[k] = v }
      end

      if Wikidata.verbose?
        Configuration.logger.debug { "[Wikidata REST] #{response.status} #{url}" }
      end

      case response.status
      when 304
        nil # Not modified — caller should use cached version
      when 200
        new_etag = response.headers["etag"]
        normalized = normalize_item(response.body, item_id)
        [normalized, new_etag]
      when 308
        # Redirect — follow it
        redirect_id = response.headers["location"]&.split("/")&.last
        fetch_item(redirect_id, etag: nil) if redirect_id
      else
        raise Wikidata::HttpError.new(response.status, url)
      end
    end

    def self.base_url
      Configuration.rest_api_url || DEFAULT_REST_URL
    end

    def self.client
      @client ||= Faraday.new do |faraday|
        faraday.headers["User-Agent"] = Configuration.user_agent || Entity.default_user_agent
        faraday.response :json, content_type: /\bjson$/
        faraday.adapter Configuration.faraday_adapter
      end
    end

    # Reset the client (useful for testing or config changes)
    def self.reset_client!
      @client = nil
    end

    # Normalize REST API response to match Action API format so the
    # rest of the gem can parse it identically.
    def self.normalize_item(rest_data, item_id)
      return rest_data unless rest_data.is_a?(Hash)

      result = {
        "type" => rest_data["type"] || "item",
        "id" => rest_data["id"] || item_id
      }

      result["labels"] = normalize_locale_map(rest_data["labels"]) if rest_data["labels"]
      result["descriptions"] = normalize_locale_map(rest_data["descriptions"]) if rest_data["descriptions"]
      result["aliases"] = normalize_aliases(rest_data["aliases"]) if rest_data["aliases"]
      result["claims"] = normalize_statements(rest_data["statements"]) if rest_data["statements"]
      result["sitelinks"] = normalize_sitelinks(rest_data["sitelinks"]) if rest_data["sitelinks"]

      result
    end

    # REST: {"en": "Douglas Adams"} → Action: {"en": {"language": "en", "value": "Douglas Adams"}}
    def self.normalize_locale_map(map)
      return {} unless map.is_a?(Hash)
      map.each_with_object({}) do |(locale, value), hash|
        hash[locale] = {"language" => locale, "value" => value}
      end
    end

    # REST: {"en": ["alias1", "alias2"]} → Action: {"en": [{"language": "en", "value": "alias1"}, ...]}
    def self.normalize_aliases(aliases_map)
      return {} unless aliases_map.is_a?(Hash)
      aliases_map.each_with_object({}) do |(locale, values), hash|
        hash[locale] = values.map { |v| {"language" => locale, "value" => v} }
      end
    end

    # REST statements → Action API claims format
    def self.normalize_statements(statements)
      return {} unless statements.is_a?(Hash)
      statements.each_with_object({}) do |(property_id, stmts), hash|
        hash[property_id] = stmts.map { |stmt| normalize_statement(stmt, property_id) }
      end
    end

    def self.normalize_statement(stmt, property_id)
      result = {
        "type" => "statement",
        "rank" => stmt["rank"] || "normal",
        "mainsnak" => normalize_snak(stmt, property_id)
      }

      if stmt["qualifiers"]&.any?
        result["qualifiers"] = {}
        stmt["qualifiers"].each do |q|
          qpid = q.dig("property", "id")
          result["qualifiers"][qpid] ||= []
          result["qualifiers"][qpid] << normalize_snak(q, qpid)
        end
      end

      if stmt["references"]&.any?
        result["references"] = stmt["references"].map do |ref|
          snaks = {}
          (ref["parts"] || []).each do |part|
            rpid = part.dig("property", "id")
            snaks[rpid] ||= []
            snaks[rpid] << normalize_snak(part, rpid)
          end
          {"snaks" => snaks}
        end
      end

      result
    end

    def self.normalize_snak(rest_snak, property_id)
      value_obj = rest_snak["value"]
      data_type = rest_snak.dig("property", "data_type") || rest_snak.dig("property", "data-type")

      snak = {
        "property" => property_id,
        "datatype" => data_type
      }

      if value_obj.nil? || value_obj["type"] == "novalue"
        snak["snaktype"] = "novalue"
      elsif value_obj["type"] == "somevalue"
        snak["snaktype"] = "somevalue"
      else
        snak["snaktype"] = "value"
        snak["datavalue"] = normalize_datavalue(value_obj["content"], data_type)
      end

      snak
    end

    def self.normalize_datavalue(content, data_type)
      case content
      when Hash
        if content.key?("time")
          {"type" => "time", "value" => content}
        elsif content.key?("amount")
          {"type" => "quantity", "value" => content}
        elsif content.key?("latitude")
          {"type" => "globecoordinate", "value" => content}
        elsif content.key?("text") && content.key?("language")
          {"type" => "monolingualtext", "value" => content}
        elsif content.key?("entity-type") || content.key?("id")
          normalize_entity_value(content)
        else
          {"type" => "unknown", "value" => content}
        end
      when String
        # REST API uses bare strings like "Q5" for entity references
        if data_type&.match?(/wikibase-item|wikibase-property/) || content.match?(/\A[QP]\d+\z/)
          normalize_entity_value({"id" => content})
        else
          {"type" => "string", "value" => content}
        end
      else
        {"type" => "unknown", "value" => content}
      end
    end

    def self.normalize_entity_value(content)
      entity_id = content["id"] || "Q#{content["numeric-id"]}"
      entity_type = content["entity-type"] || (entity_id.start_with?("P") ? "property" : "item")
      numeric_id = entity_id.sub(/\A[QPL]/, "").to_i
      {"type" => "wikibase-entityid", "value" => {"entity-type" => entity_type, "numeric-id" => numeric_id, "id" => entity_id}}
    end

    # REST: {"enwiki": {"title": "...", "badges": [], "url": "..."}}
    # Action: {"enwiki": {"site": "enwiki", "title": "...", "badges": []}}
    def self.normalize_sitelinks(sitelinks)
      return {} unless sitelinks.is_a?(Hash)
      sitelinks.each_with_object({}) do |(site, data), hash|
        hash[site] = {"site" => site, "title" => data["title"], "badges" => data["badges"] || []}
      end
    end
  end
end
