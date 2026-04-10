# frozen_string_literal: true

module Wikidata
  class IdentityMap < Wikidata::HashedObject
    CACHE_PREFIX = "wikidata:entity:"

    CacheEntry = Struct.new(:value, :expires_at)

    @mutex = Mutex.new
    @identity_map = {}

    def self.if_uncached(key, &block)
      if (cached = cached_value(key))
        cached
      else
        block.call
      end
    end

    def self.cached_value(key)
      if (store = Configuration.cache_store)
        raw = store.read("#{CACHE_PREFIX}#{key}")
        raw && Wikidata::Item.new(raw)
      else
        @mutex.synchronize do
          entry = @identity_map[key]
          return nil unless entry
          if entry.expires_at && entry.expires_at < Time.now
            @identity_map.delete(key)
            nil
          else
            entry.value
          end
        end
      end
    end

    def self.cache!(key, value)
      if (store = Configuration.cache_store)
        store.write("#{CACHE_PREFIX}#{key}", value.data_hash.to_h, expires_in: Configuration.cache_ttl)
      else
        ttl = Configuration.cache_ttl
        expires_at = ttl ? Time.now + ttl : nil
        @mutex.synchronize { @identity_map[key] = CacheEntry.new(value, expires_at) }
      end
    end

    def self.reset!
      @mutex.synchronize { @identity_map.clear }
    end
  end
end
