module Wikidata
  module DataValues
    class String < Wikidata::DataValues::Value

      def to_s
        data_hash.string
      end

    end
  end
end
