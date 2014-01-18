module Wikidata
  class Entity < Wikidata::HashedObject

    def self.find_all_by_id id, query = {}
      query = {
        action: 'wbgetentities',
        sites: 'enwiki',
        ids: id,
        format: 'json'
      }.merge(Wikidata.default_languages_hash).merge(query)
      response = HTTParty.get('http://www.wikidata.org/w/api.php', {query: query})
      response['entities'].map do |entity_id, entity_hash|
        new(entity_hash)
      end
    end

    def self.find_by_id *args
      find_all_by_id(*args).first
    end

    def self.find_all_by_title title, query = {}
      find_all_by_id(nil, query.merge(titles: title))
    end

    def self.find_by_title *args
      find_all_by_title(*args).first
    end

    def inspect
      "<#{self.class.to_s} id=#{id}>"
    end

    def label(locale = I18n.default_locale)
      h = self.data_hash.labels[locale.to_s]
      h ? h.value : nil
    end

  end
end
