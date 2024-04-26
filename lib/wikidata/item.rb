module Wikidata
  class Item < Wikidata::Entity
    def claims
      @claims ||= if data_hash.claims
        data_hash.claims.map do |statement_type, statement_array|
          statement_array.map do |statement_hash|
            Wikidata::Statement.new(statement_hash)
          end
        end.flatten
      else
        []
      end
    end

    def resolve_claims!
      ids = []
      claims.each do |claim|
        ids << claim.mainsnak.property_id
        ids << claim.mainsnak.value.item_id if claim.mainsnak.value.instance_of?(Wikidata::DataValues::Entity)
      end
      self.class.find_all_by_id ids
    end

    def claims_for_property_id(property_id)
      claims.select { |c| c.mainsnak.property_id == property_id }
    end

    def entities_for_property_id(property_id)
      Wikidata::Item.find_all_by_id(item_ids_for_property_id(property_id))
    end

    def item_ids_for_property_id(property_id)
      presets = Wikidata::Configuration.property_presets
      property_id = presets[property_id.to_sym] if presets.include?(property_id.to_sym)
      claims_for_property_id(property_id).map { |c| c.mainsnak.value.item_id }
    end

    # Convenience methods

    def instance_of
      entities_for_property_id(:instance_of)
    end

    def subclass_of
      entities_for_property_id(:subclass_of)
    end

    def subclass_of?(entity_id, depth: 0)
      return true if Array.wrap(entity_id).include?(id)
      return false if depth <= 0

      subclass_of.any? do |entity|
        entity.subclass_of?(entity_id, depth: depth - 1)
      end
    end

    def entity_instance_of?(entity_id, depth: 0)
      return true if Array.wrap(entity_id).include?(id)
      return false if depth <= 0

      instance_of.any? { |entity| entity.subclass_of?(entity_id, depth: depth - 1) }
    end

    def instance_or_subclass_of?(entity_ids, depth: 0)
      entity_ids = Array.wrap(entity_ids)
      return true if entity_ids.include?(id)

      queue = Entity.find_all_by_id(item_ids_for_property_id(:instance_of) + item_ids_for_property_id(:subclass_of))
      current_depth = 0

      while current_depth < depth && !queue.empty?
        current_entity = queue.shift

        return true if entity_ids.include?(current_entity.id)

        queue.concat(Entity.find_all_by_id(current_entity.item_ids_for_property_id(:instance_of) + current_entity.item_ids_for_property_id(:subclass_of)))
        current_depth += 1
      end

      false
    end

    def image
      image_claims = [
        claims_for_property_id("P18").last,
        claims_for_property_id("P154").last
      ].compact
      image_claims.first&.mainsnak&.value
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
