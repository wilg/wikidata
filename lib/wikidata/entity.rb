module Wikidata
  class Entity < Wikidata::HashedObject

    def self.find_all query
      query = {
        action: 'wbgetentities',
        sites: 'enwiki',
        format: 'json'
      }.merge(Wikidata.default_languages_hash).merge(query)
      response = HTTParty.get('http://www.wikidata.org/w/api.php', {query: query})
      response['entities'].map do |entity_id, entity_hash|
        new(entity_hash)
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

    def inspect
      "<#{self.class.to_s} id=#{id}>"
    end

    def delocalize(hash, locale = I18n.default_locale)
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
