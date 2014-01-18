require 'httparty'
require 'hashie'
require 'i18n'
require "wikidata/version"
require "wikidata/entity"
require "wikidata/item"
require "wikidata/property"
require "wikidata/statement"
require "wikidata/snak"

module Wikidata

  def self.use_only_default_language
    true
  end

  def self.default_languages_hash
    use_only_default_language ? {languages: I18n.default_locale} : {}
  end

end
