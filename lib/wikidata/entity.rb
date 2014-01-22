module Wikidata
  class Entity < Wikidata::HashedObject

    def self.find_all query
      query = create_query query
      response = HTTParty.get('http://www.wikidata.org/w/api.php', {query: query})
      # puts "Getting: #{query}"
      response['entities'].map do |entity_id, entity_hash|
        new(entity_hash)
      end
    end

    def self.wikify_string string
      if string
        string[0].upcase + string[1..string.size].gsub(' ', '_')
      end
    end

    def self.create_query query
      Wikidata::IdentityMap.cache "#{query.hash}" do
        query = {
          action: 'wbgetentities',
          sites: 'enwiki',
          format: 'json'
        }.merge(Wikidata.default_languages_hash).merge(query)
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
      response = find_all_by_title(*args).first
      if response.has_content?
        response
      else
        str = wikify_string(args.first)
        puts "response has no content, trying again with #{str}!"
        arr = [str, args[1..args.size]].flatten!
        response = find_all_by_title(*arr).first
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

  end
end
