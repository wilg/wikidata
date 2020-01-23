module Wikidata
  class Configuration
    class << self
      attr_accessor :verbose, :use_only_default_language, :client_options, :property_presets, :faraday_adapter

      def configure &block
        yield self
      end
    end

    @verbose = false
    @use_only_default_language = true
    @client_options = {}
    @faraday_adapter = :patron
    @property_presets = {
      mother:   "P25",
      father:   "P22",
      children: "P40",
      doctoral_advisor: "P184"
    }
  end
end
