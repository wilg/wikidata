module Wikidata
  class IdentityMap < Wikidata::HashedObject

    def self.cache(key, &block)
      @@identity_map ||= {}
      if cached_value = @@identity_map[key]
        return cached_value
      else
        content = block.call
        cache! key, content
        return content
      end
    end

    def self.cache!(key, value)
      @@identity_map ||= {}
      @@identity_map[key] = value
    end

  end
end
