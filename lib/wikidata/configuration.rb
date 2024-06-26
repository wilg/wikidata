module Wikidata
  class Configuration
    class << self
      attr_accessor :verbose, :use_only_default_language, :client_options, :property_presets, :faraday_adapter

      def configure &block
        yield self
      end

      def faraday(&block)
        @faraday = block
      end

      def apply_faraday(faraday)
        @faraday&.call(faraday)
      end
    end

    @verbose = false
    @use_only_default_language = true
    @client_options = {}
    @faraday_adapter = :net_http
    @property_presets = {
      mother: "P25",
      father: "P22",
      children: "P40",
      doctoral_advisor: "P184",
      instance_of: "P31",
      subclass_of: "P279",
    }
  end
end
