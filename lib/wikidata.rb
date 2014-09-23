require 'faraday'
require 'faraday_middleware'
require 'hashie'
require 'i18n'
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

module Wikidata

  class << self

    def configure &block
      Configuration.configure &block
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
  end
end
