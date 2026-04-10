module Wikidata
  module DataValues
    class SomeValue < Wikidata::DataValues::Value
      def to_s
        "Unknown value"
      end
    end
  end
end
