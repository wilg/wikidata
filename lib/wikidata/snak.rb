module Wikidata
  class Snak < Wikidata::HashedObject
    def property_id
      data_hash.property
    end

    def property
      @property ||= Wikidata::Property.find_by_id(property_id)
    end

    def no_value?
      @data_hash["snaktype"] == "novalue"
    end

    def some_value?
      @data_hash["snaktype"] == "somevalue"
    end

    def unknown?
      no_value? || some_value?
    end

    def value
      @value ||= if @data_hash["snaktype"] == "novalue"
        Wikidata::DataValues::NoValue.new({})
      elsif @data_hash["snaktype"] == "somevalue"
        Wikidata::DataValues::SomeValue.new({})
      elsif @data_hash["datavalue"].nil?
        nil
      elsif datavalue["type"] == "wikibase-entityid"
        Wikidata::DataValues::Entity.new(datavalue.value)
      elsif datavalue["type"] == "time"
        if datavalue.value.precision >= 11
          Wikidata::DataValues::Time.new(datavalue.value)
        else
          Wikidata::DataValues::Year.new(datavalue.value)
        end
      elsif datavalue["type"] == "quantity"
        Wikidata::DataValues::Quantity.new(datavalue.value)
      elsif datavalue["type"] == "monolingualtext"
        Wikidata::DataValues::MonolingualText.new(datavalue.value)
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
