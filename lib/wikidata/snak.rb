# frozen_string_literal: true

module Wikidata
  class Snak < Wikidata::HashedObject
    @value_handlers = {}

    def self.register_value_handler(type, &block)
      @value_handlers[type] = block
    end

    def self.value_handlers
      @value_handlers
    end

    register_value_handler("wikibase-entityid") { |dv, _snak| DataValues::Entity.new(dv.value) }
    register_value_handler("time") do |dv, _snak|
      if dv.value.precision >= 11
        DataValues::Time.new(dv.value)
      else
        DataValues::Year.new(dv.value)
      end
    end
    register_value_handler("quantity") { |dv, _snak| DataValues::Quantity.new(dv.value) }
    register_value_handler("monolingualtext") { |dv, _snak| DataValues::MonolingualText.new(dv.value) }
    register_value_handler("globecoordinate") { |dv, _snak| DataValues::Globecoordinate.new(dv.value) }
    register_value_handler("string") do |dv, snak|
      if snak.datatype == "commonsMedia"
        DataValues::CommonsMedia.new({imagename: dv.value})
      else
        DataValues::String.new({string: dv.value})
      end
    end

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
      elsif (handler = self.class.value_handlers[datavalue["type"]])
        handler.call(datavalue, self)
      else
        datavalue
      end
    end

    def inspect
      "<#{self.class} type=#{snaktype} property_id=#{property_id}>"
    end
  end
end
