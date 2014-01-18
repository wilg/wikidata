module Wikidata
  class Item < Wikidata::Entity

    def claims
      @claims ||= self.data_hash.claims.map do |statement_type, statement_array|
        statement_array.map do |statement_hash|
          Wikidata::Statement.new(statement_hash)
        end
      end.flatten
    end

    def simple_properties
      @simple_properties ||= begin
        h = {}
        self.claims.map do |claim|
          h[claim.mainsnak.property_id] = claim.mainsnak.value
        end
        h
      end
    end

    def resolved_properties
      props = simple_properties
      h = {}
      simple_properties.each do |k, v|
        v.resolve! if v.respond_to?(:resolve!)
        h[Wikidata::Property.find_by_id(k)] = v
      end
      h
    end

  end
end
