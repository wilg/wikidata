require "active_support/core_ext/array"

module Wikidata
  class Entity < Wikidata::HashedObject
    BASE_URL = 'http://www.wikidata.org/w/api.php'.freeze

    def self.find_all query

      found_objects = []

      query = {
        action: 'wbgetentities',
        sites: 'enwiki',
        format: 'json'
      }.merge(Wikidata.default_languages_hash).merge(query)

      query[:languages] = query[:languages].join('|') if query[:languages].is_a? Array

      ids = query[:ids] || []
      titles = query[:titles] || []

      # Split IDs and titles
      ids = ids.split("|") if ids && ids.class == String
      titles = titles.split("|") if titles && titles.class == String

      # Reject already cached values
      fetchable_ids = ids.reject do |id|
        if val = IdentityMap.cached_value(id)
          found_objects << val
          true
        else
          false
        end
      end
      fetchable_titles = titles.reject do |title|
        if val = IdentityMap.cached_value(title)
          found_objects << val
          true
        else
          false
        end
      end

      # Fetch by IDs
      if fetchable_ids.length > 0
        fetchable_ids.in_groups_of(50, false) do |group|
          found_objects.concat query_and_build_objects(query.merge(ids: group.join("|")))
        end
      end

      # Fetch by titles
      if fetchable_titles.length > 0
        fetchable_titles.in_groups_of(50, false) do |group|
          found_objects.concat query_and_build_objects(query.merge(titles: group.join("|")))
        end
      end

      found_objects
    end

    def self.query_and_build_objects(query)
      response = client.get '', query
      puts "Getting: #{query}".yellow if Wikidata.verbose?
      return unless response.status == 200
      response.body['entities'].map do |entity_id, entity_hash|
        item = new(entity_hash)
        IdentityMap.cache!(entity_id, item)
        item
      end
    end

    def self.find_all_by_id id, query = {}
      find_all({ids: id}.merge(query))
    end

    def self.find_by_id *args
      find_all_by_id(*args).first
    end

    def self.find_all_by_title title, query = {}
      find_all({titles: title}.merge(query))
    end

    def self.find_by_title *args
      find_all_by_title(*args).first
    end

    # Search for resources on wikidata api.
    # @param <String> search, the pattern to search.
    # @param <Hash> args.
    #  - query: Customise search
    #  - options: Customize resource
    # @return <Array>
    def self.search search, args = {}
      query = {
        action: 'query',
        list: 'search',
        format: 'json',
        srlimit: 10,
        srsearch: search
      }.merge(args[:query] || {})
      options = args[:options] || {}

      response = client.get '', query
      if response.status == 200 && (items = response.body['query']['search']).present?
        Wikidata::Item.find_all_by_id items.map{|i| i['title']}, options
      else
        []
      end
    end

    def inspect
      "<#{self.class.to_s} id=#{id}>"
    end

    def delocalize(hash, locale = I18n.default_locale)
      return nil unless hash
      h = hash[locale.to_s]
      h ? h.value : nil
    end

    def label(*args)
      delocalize self.data_hash.labels, *args
    end

    def description(*args)
      delocalize self.data_hash.descriptions, *args
    end

    def self.client
      @_client ||= Faraday.new({url: BASE_URL}.merge(Wikidata.client_options)) do |faraday|
        faraday.request  :url_encoded
        faraday.response :json, :content_type => /\bjson$/
        faraday.adapter  :patron
      end
    end

  end
end
