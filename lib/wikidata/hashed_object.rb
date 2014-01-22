module Wikidata
  class HashedObject

    attr_reader :data_hash

    def initialize(data_hash)
      @data_hash = Hashie::Mash.new(data_hash)
    end

    def method_missing(meth, *args, &block)
      if data_hash.has_key?(meth.to_s)
        data_hash[meth.to_s]
      else
        super
      end
    end

    def has_content?
      data_hash.missing.nil?
    end

  end
end
