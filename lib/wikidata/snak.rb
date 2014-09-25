module Wikidata
  class Snak < Wikidata::HashedObject

    def property_id
      data_hash.property
    end

    def property
      @property ||= Wikidata::Property.find_by_id(property_id)
    end

    def value
      @value ||= begin
        if snaktype == "somevalue"
          Wikidata::DataValues::String.new({string: "Unknown"})
        elsif datavalue['type'] == "wikibase-entityid"
          Wikidata::DataValues::Entity.new(datavalue.value)
        elsif datavalue['type'] == "time"
          Wikidata::DataValues::Time.new(datavalue.value)
        elsif datavalue['type'] == "globecoordinate"
          Wikidata::DataValues::Globecoordinate.new(datavalue.value)
        elsif datavalue['type'] == 'string'
          if property_id == "P18" || (@property && @property.datatype == "commonsMedia")
            Wikidata::DataValues::CommonsMedia.new({imagename: datavalue.value})
          else
            Wikidata::DataValues::String.new({string: datavalue.value})
          end
        else
          datavalue
        end
      end
    end

    def inspect
      "<#{self.class.to_s} type=#{snaktype} property_id=#{property_id}>"
    end

  end
end
