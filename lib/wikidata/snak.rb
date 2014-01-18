module Wikidata
  class Snak < Wikidata::Entity

    def property_id
      hash.property
    end

    def property
      @property ||= Wikidata::Property.find_by_id(property_id)
    end

    def value(resolve = true)
      if datavalue.type == "wikibase-entityid"
        "#{datavalue.value['entity-type']}/#{datavalue.value['numeric-id']}"
      elsif datavalue.type == 'string'
        return datavalue.value
      end
    end

    def inspect
      "<#{self.class.to_s} type=#{snaktype} property_id=#{property_id}>"
    end

  end
end
