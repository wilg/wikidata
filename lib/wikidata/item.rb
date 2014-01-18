module Wikidata
  class Item < Wikidata::Entity

    def claims
      @claims ||= begin
        if self.data_hash.claims
          self.data_hash.claims.map do |statement_type, statement_array|
            statement_array.map do |statement_hash|
              Wikidata::Statement.new(statement_hash)
            end
          end.flatten
        else
          []
        end
      end
    end

    def claims_for_property_id(property_id)
      claims.select{|c| c.mainsnak.property_id == property_id }
    end

    def entities_for_property_id(property_id)
      presets = {
        mother:   "P25",
        father:   "P22",
        children: "P40",
        doctoral_advisor: "P184"
      }
      property_id = presets[property_id.to_sym] if presets.include?(property_id.to_sym)
      claims_for_property_id(property_id).map{|c| c.mainsnak.value.entity }
    rescue
      []
    end

  end
end
