module Wikidata
  class Entity

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

    def label(locale = I18n.default_locale)
      h = self.hash.labels[locale.to_s]
      h ? h.value : nil
    end

  end
end
