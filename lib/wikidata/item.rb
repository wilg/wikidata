module Wikidata
  class Item < Wikidata::Entity

    attr_reader :claims

    def self.find_all_by_title title, query = {}
      query = {
        action: 'wbgetentities',
        sites: 'enwiki',
        titles: title,
        # languages: I18n.default_locale,
        format: 'json'
      }.merge(query)
      response = HTTParty.get('http://www.wikidata.org/w/api.php', {query: query})
      response['entities'].map do |entity_id, entity_hash|
        new(entity_hash)
      end
    end

    def label(locale = I18n.default_locale)
      h = self.hash.labels[locale.to_s]
      h ? h.value : nil
    end

    def initialize(hash)
      super
      @claims = self.hash.claims.map do |statement_type, statement_array|
        statement_array.map do |statement_hash|
          Wikidata::Statement.new(statement_hash)
        end
      end.flatten
    end

    def self.find_by_title *args
      find_all_by_title(*args).first
    end

  end
end
