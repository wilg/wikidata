module Wikidata
  class MashSubclass < Hashie::Mash
    disable_warnings
  end

  class HashedObject
    attr_reader :data_hash

    def initialize(data_hash)
      @data_hash = MashSubclass.new(data_hash)
    end

    def respond_to_missing?(method_name, include_private = false)
      data_hash.has_key?(method_name.to_s)
    end

    def method_missing(method_name, *args, &block)
      if data_hash.has_key?(method_name.to_s)
        data_hash[method_name.to_s]
      else
        super
      end
    end
  end
end
