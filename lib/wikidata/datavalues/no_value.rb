module Wikidata
  module DataValues
    class NoValue < Wikidata::DataValues::Value
      def to_s
        "No value"
      end
    end
  end
end
