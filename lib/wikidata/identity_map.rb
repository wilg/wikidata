# frozen_string_literal: true

module Wikidata
  class IdentityMap < Wikidata::HashedObject
    CACHE_PREFIX = "wikidata:entity:"

    CacheEntry = Struct.new(:value, :expires_at, :etag)

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

    def self.cache!(key, value, etag: nil)
      if (store = Configuration.cache_store)
        data = value.data_hash.to_h
        data["_etag"] = etag if etag
        store.write("#{CACHE_PREFIX}#{key}", data, expires_in: Configuration.cache_ttl)
      else
        ttl = Configuration.cache_ttl
        expires_at = ttl ? Time.now + ttl : nil
        @mutex.synchronize { @identity_map[key] = CacheEntry.new(value, expires_at, etag) }
      end
    end

    def self.etag_for(key)
      if (store = Configuration.cache_store)
        raw = store.read("#{CACHE_PREFIX}#{key}")
        raw&.dig("_etag")
      else
        @mutex.synchronize { @identity_map[key]&.etag }
      end
    end

    def self.refresh_ttl!(key)
      if (store = Configuration.cache_store)
        raw = store.read("#{CACHE_PREFIX}#{key}")
        store.write("#{CACHE_PREFIX}#{key}", raw, expires_in: Configuration.cache_ttl) if raw
      else
        ttl = Configuration.cache_ttl
        @mutex.synchronize do
          entry = @identity_map[key]
          entry.expires_at = ttl ? Time.now + ttl : nil if entry
        end
      end
    end

    def self.reset!
      @mutex.synchronize { @identity_map.clear }
    end
  end
end
