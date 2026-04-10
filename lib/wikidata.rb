# frozen_string_literal: true

require "faraday"
require "hashie"
require "i18n"
require "wikidata/version"
require "wikidata/configuration"
require "wikidata/hashed_object"
require "wikidata/identity_map"
require "wikidata/entity"
require "wikidata/item"
require "wikidata/property"
require "wikidata/statement"
require "wikidata/snak"
require "wikidata/datavalues/value"
require "wikidata/datavalues/string"
require "wikidata/datavalues/commons_media"
require "wikidata/datavalues/time"
require "wikidata/datavalues/globecoordinate"
require "wikidata/datavalues/entity"
require "wikidata/datavalues/year"
require "wikidata/datavalues/some_value"
require "wikidata/datavalues/no_value"
require "wikidata/rest_client"
require "wikidata/sparql"
require "wikidata/datavalues/quantity"
require "wikidata/datavalues/monolingual_text"

module Wikidata
  class Error < StandardError; end

  class HttpError < Error
    attr_reader :status, :url

    def initialize(status, url)
      @status = status
      @url = url
      super("Wikidata API returned HTTP #{status}: #{url}")
    end
  end

  class NotFoundError < Error; end

  class MaxlagError < Error
    attr_reader :lag, :retry_after

    def initialize(lag, retry_after)
      @lag = lag
      @retry_after = retry_after
      super("Wikidata server lagged #{lag}s, retry after #{retry_after}s")
    end
  end

  class RateLimitError < HttpError
    attr_reader :retry_after

    def initialize(url, retry_after)
      @retry_after = retry_after
      super(429, url)
    end
  end

  class << self
    def configure(&block)
      Configuration.configure(&block)
    end

    def use_only_default_language?
      Configuration.use_only_default_language
    end

    def default_languages_hash
      use_only_default_language? ? {languages: I18n.default_locale} : {}
    end

    def verbose?
      !!Configuration.verbose
    end

    def verbose=(v)
      Configuration.verbose = !!v
    end

    def client_options
      Configuration.client_options
    end

    def logger
      Configuration.logger
    end

    def logger=(logger)
      Configuration.logger = logger
    end
  end
end
