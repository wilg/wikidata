module Wikidata
  class Configuration
    class << self
      attr_accessor :verbose, :use_only_default_language, :client_options

      def configure &block
        yield self
      end
    end

    @verbose = false
    @use_only_default_language = true
    @client_options = {}
  end
end
