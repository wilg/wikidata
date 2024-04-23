module Wikidata
  class Snak < Wikidata::HashedObject
    def property_id
      data_hash.property
    end

    def property
      @property ||= Wikidata::Property.find_by_id(property_id)
    end

    def value
      @value ||= if @data_hash["snaktype"] == "novalue" || @data_hash["snaktype"] == "somevalue" || @data_hash["datavalue"].nil?
        nil
      elsif datavalue["type"] == "wikibase-entityid"
        Wikidata::DataValues::Entity.new(datavalue.value)
      elsif datavalue["type"] == "time"
        if datavalue.value.precision >= 11
          Wikidata::DataValues::Time.new(datavalue.value)
        elsif datavalue.value.precision == 9
          Wikidata::DataValues::Year.new(datavalue.value)
        else
          datavalue
        end
      elsif datavalue["type"] == "globecoordinate"
        Wikidata::DataValues::Globecoordinate.new(datavalue.value)
      elsif datavalue["type"] == "string"
        if datatype == "commonsMedia"
          Wikidata::DataValues::CommonsMedia.new({imagename: datavalue.value})
        else
          Wikidata::DataValues::String.new({string: datavalue.value})
        end
      else
        datavalue
      end
    end

    def inspect
      "<#{self.class} type=#{snaktype} property_id=#{property_id}>"
    end
  end
end
