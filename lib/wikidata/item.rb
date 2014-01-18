module Wikidata
  class Item < Wikidata::Entity

    def self.find_all_by_title title, query = {}
      query = {
        action: 'wbgetentities',
        sites: 'enwiki',
        titles: title,
        format: 'json'
      }.merge(Wikidata.default_languages_hash).merge(query)
      response = HTTParty.get('http://www.wikidata.org/w/api.php', {query: query})
      response['entities'].map do |entity_id, entity_hash|
        new(entity_hash)
      end
    end

    def self.find_by_title *args
      find_all_by_title(*args).first
    end

    def claims
      @claims ||= self.hash.claims.map do |statement_type, statement_array|
        statement_array.map do |statement_hash|
          Wikidata::Statement.new(statement_hash)
        end
      end.flatten
    end

    def simple_properties
      h = {}
      self.claims.map do |claim|
        h[claim.mainsnak.property.label] = claim.mainsnak.datavalue.value
      end
      h
    end

  end
end
