module Wikidata
  class Property < Wikidata::Entity

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

  end
end
