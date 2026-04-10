# frozen_string_literal: true

module Wikidata
  class Sparql
    DEFAULT_ENDPOINT = "https://query.wikidata.org/sparql"

    def self.query(sparql, endpoint: nil)
      url = endpoint || Configuration.sparql_endpoint || DEFAULT_ENDPOINT
      response = client(url).get("", {query: sparql, format: "json"})

      unless response.status == 200
        raise Wikidata::HttpError.new(response.status, url)
      end

      results = response.body.dig("results", "bindings")
      results || []
    end

    def self.item_ids(sparql, variable: "item", **args)
      query(sparql, **args).filter_map do |binding|
        uri = binding.dig(variable, "value")
        uri&.split("/")&.last
      end
    end

    def self.items(sparql, variable: "item", **args)
      ids = item_ids(sparql, variable: variable, **args)
      return [] if ids.empty?
      Wikidata::Item.find_all_by_id(ids.join("|"))
    end

    def self.client(url)
      Faraday.new(url: url) do |faraday|
        faraday.headers["User-Agent"] = Entity.default_user_agent
        faraday.headers["Accept"] = "application/sparql-results+json"
        faraday.request :url_encoded
        faraday.response :json, content_type: /\bjson$/
        faraday.adapter Wikidata::Configuration.faraday_adapter
      end
    end
  end
end
