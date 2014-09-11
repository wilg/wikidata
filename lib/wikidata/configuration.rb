module Wikidata
  class Configuration
    class << self
      attr_accessor :verbose, :use_only_default_language

      def configure &block
        yield self
      end
    end

    @verbose = false
    @use_only_default_language = true
  end
end
