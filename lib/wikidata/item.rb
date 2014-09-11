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

    def resolve_claims!
      ids = []
      claims.each do |claim|
        ids << claim.mainsnak.property_id
        ids << claim.mainsnak.value.item_id if claim.mainsnak.value.class == Wikidata::DataValues::Entity
      end
      self.class.find_all_by_id ids
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

    # Convenience methods

    def image
      image_claim = claims_for_property_id("P18").first
      image_claim.mainsnak.value if image_claim
    end

    def websites
      website_claims = claims_for_property_id("P856")
      return [] unless website_claims.present?
      website_claims.map(&:mainsnak).map(&:value).map(&:string)
    end

    def mothers
      entities_for_property_id :mother
    end

    def fathers
      entities_for_property_id :father
    end

    def children
      entities_for_property_id :children
    end

    def doctoral_advisors
      entities_for_property_id :doctoral_advisor
    end

  end
end
