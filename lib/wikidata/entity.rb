# frozen_string_literal: true

module Wikidata
  class Entity < Wikidata::HashedObject
    DEFAULT_API_URL = "https://www.wikidata.org/w/api.php"

    def self.find_all(query)
      found_objects = []

      defaults = {
        action: "wbgetentities",
        sites: "enwiki",
        format: "json",
        languagefallback: ""
      }
      defaults[:props] = Configuration.default_props if Configuration.default_props
      defaults[:sitefilter] = Configuration.sitefilter if Configuration.sitefilter
      query = defaults.merge(default_query_params).merge(Wikidata.default_languages_hash).merge(query)

      query[:languages] = query[:languages].join("|") if query[:languages].is_a? Array

      ids = query[:ids] || []
      titles = query[:titles] || []

      # Split IDs and titles
      ids = ids.split("|") if ids&.instance_of?(String)
      titles = titles.split("|") if titles&.instance_of?(String)

      # Reject already cached values
      fetchable_ids = ids.reject do |id|
        if (val = IdentityMap.cached_value(id))
          found_objects << val
          true
        else
          false
        end
      end
      fetchable_titles = titles.reject do |title|
        if (val = IdentityMap.cached_value(title))
          found_objects << val
          true
        else
          false
        end
      end

      # Fetch by IDs
      if fetchable_ids.length > 0
        fetchable_ids.each_slice(50) do |group|
          found_objects.concat query_and_build_objects(query.merge(ids: group.join("|")))
        end
      end

      # Fetch by titles
      if fetchable_titles.length > 0
        fetchable_titles.each_slice(50) do |group|
          found_objects.concat query_and_build_objects(query.merge(titles: group.join("|")))
        end
      end

      found_objects
    end

    def self.query_and_build_objects(query)
      response = get "", query
      unless response.status == 200
        raise Wikidata::HttpError.new(response.status, response.env.url.to_s)
      end
      response.body["entities"].map do |entity_id, entity_hash|
        if entity_id.to_i != -1
          item = Wikidata::Item.new(entity_hash)
          # Cache under the requested ID
          IdentityMap.cache!(entity_id, item)
          # Also cache under the real ID if this was a redirect
          real_id = entity_hash["id"] || entity_hash[:id]
          if real_id && real_id.to_s != entity_id.to_s
            IdentityMap.cache!(real_id.to_s, item)
          end
          item
        end
      end.compact
    end

    def self.find_all_by_id(id, props: nil, sitefilter: nil, **query)
      q = {ids: id}.merge(query)
      q[:props] = props if props
      q[:sitefilter] = sitefilter if sitefilter
      find_all(q)
    end

    def self.find_by_id(id, **args)
      find_all_by_id(id, **args).first
    end

    def self.find_all_by_title(title, props: nil, sitefilter: nil, **query)
      q = {titles: title}.merge(query)
      q[:props] = props if props
      q[:sitefilter] = sitefilter if sitefilter
      find_all(q)
    end

    def self.find_by_title(title, **args)
      find_all_by_title(title, **args).first
    end

    # Search for resources on wikidata api.
    # @param <String> search, the pattern to search.
    # @param <Hash> args.
    #  - query: Customise search
    #  - options: Customize resource
    # @return <Array>
    def self.search(search, limit: 10, offset: 0, **args)
      query = {
        action: "query",
        list: "search",
        format: "json",
        srlimit: limit,
        sroffset: offset,
        srsearch: search
      }.merge(default_query_params).merge(args[:query] || {})
      options = args[:options] || {}

      response = get "", query
      unless response.status == 200
        raise Wikidata::HttpError.new(response.status, response.env.url.to_s)
      end
      items = response.body["query"]["search"]
      if items && !items.empty?
        Wikidata::Item.find_all_by_id items.map { |i| i["title"] }, **options
      else
        []
      end
    end

    def redirected?
      data_hash.redirects.is_a?(Hash) || data_hash.redirects.respond_to?(:from)
    end

    def redirected_from
      data_hash.redirects&.from
    end

    def inspect
      "<#{self.class} id=#{id} label=#{label.inspect}>"
    end

    def delocalize(hash, locale = I18n.default_locale)
      return nil unless hash
      h = hash[locale.to_s]
      h&.value
    end

    def label(*args)
      delocalize data_hash.labels, *args
    end

    def label_language(locale = I18n.default_locale)
      h = data_hash.labels&.dig(locale.to_s)
      return nil unless h
      h["language"] || locale.to_s
    end

    def label_is_fallback?(locale = I18n.default_locale)
      h = data_hash.labels&.dig(locale.to_s)
      return false unless h
      h.key?("for-language")
    end

    def description(*args)
      delocalize data_hash.descriptions, *args
    end

    def all_labels
      return {} unless data_hash.labels
      data_hash.labels.each_with_object({}) do |(locale, entry), hash|
        hash[locale] = entry.value
      end
    end

    def all_descriptions
      return {} unless data_hash.descriptions
      data_hash.descriptions.each_with_object({}) do |(locale, entry), hash|
        hash[locale] = entry.value
      end
    end

    def aliases(locale = I18n.default_locale)
      entries = data_hash.aliases&.dig(locale.to_s)
      return [] unless entries
      entries.map { |a| a["value"] || a.value }
    end

    def sitelinks
      data_hash.sitelinks
    end

    def sitelink(site = "enwiki")
      data_hash.sitelinks&.dig(site)
    end

    def self.default_query_params
      params = {}
      params[:maxlag] = Configuration.maxlag if Configuration.maxlag
      params
    end

    def self.get(*args)
      retries = 0
      begin
        res = client.get(*args)
        Configuration.logger.debug { "[Wikidata] #{res.env.url}" } if Wikidata.verbose?

        if res.status == 429
          retry_after = res.headers["retry-after"]&.to_i || 5
          raise Wikidata::RateLimitError.new(res.env.url.to_s, retry_after)
        end

        # maxlag errors return HTTP 200 with error in body
        if res.body.is_a?(Hash) && res.body.dig("error", "code") == "maxlag"
          lag = res.body.dig("error", "lag")
          retry_after = res.headers["retry-after"]&.to_i || 5
          raise Wikidata::MaxlagError.new(lag, retry_after)
        end

        res
      rescue Wikidata::RateLimitError, Wikidata::MaxlagError => e
        if retries < Configuration.max_retries
          retries += 1
          Configuration.logger.warn { "[Wikidata] #{e.message}, retry #{retries}/#{Configuration.max_retries}" }
          sleep(e.retry_after)
          retry
        else
          raise
        end
      end
    end

    def self.default_user_agent
      "wikidata-ruby/#{Wikidata::VERSION} (https://github.com/wilg/wikidata)"
    end

    def self.client
      Faraday.new({url: Configuration.api_url || DEFAULT_API_URL}.merge(Wikidata.client_options)) do |faraday|
        faraday.headers["User-Agent"] = Configuration.user_agent || default_user_agent
        faraday.request :url_encoded
        faraday.response :json, content_type: /\bjson$/
        faraday.adapter Wikidata::Configuration.faraday_adapter
        Configuration.apply_faraday(faraday)
      end
    end
  end
end
