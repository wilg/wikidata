module Wikidata
  class IdentityMap < Wikidata::HashedObject
    def self.if_uncached(key, &block)
      if (cached = cached_value(key))
        cached
      else
        block.call
      end
    end

    def self.cached_value(key)
      @@identity_map ||= {}
      @@identity_map[key]
    end

    def self.cache!(key, value)
      @@identity_map ||= {}
      @@identity_map[key] = value
    end
  end
end
