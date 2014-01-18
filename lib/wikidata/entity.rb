module Wikidata
  class Entity < Wikidata::Object

    attr_reader :hash

    def self.find_all_by_title title, query = {}
      query = {
        action: 'wbgetentities',
        sites: 'enwiki',
        titles: title,
        languages: 'en',
        format: 'json'
      }.merge(query)
      response = HTTParty.get('http://www.wikidata.org/w/api.php', {query: query})
      response['entities'].map do |entity_id, entity_hash|
        new(entity_hash)
      end
    end

    def self.find_by_title *args
      find_all_by_title(*args).first
    end

  end
end
