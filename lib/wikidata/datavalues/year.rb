module Wikidata
  module DataValues
    class Year < Wikidata::DataValues::Value
      def to_i
        data_hash.time.split("-").first.to_i
      end

      def to_s
        to_i.to_s
      end
    end
  end
end
