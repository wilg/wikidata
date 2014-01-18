module Wikidata
  class Object

    attr_reader :hash

    def initialize(hash)
      @hash = Hashie::Mash.new(hash)
    end

    def inspect
      "<#{self.class.to_s} id=#{id}>"
    end

    def method_missing(meth, *args, &block)
      if hash.has_key?(meth.to_s)
        hash[meth.to_s]
      else
        super
      end
    end

  end
end
