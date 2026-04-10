module Wikidata
  module DataValues
    class MonolingualText < Wikidata::DataValues::Value
      def text
        data_hash.text
      end

      def language
        data_hash.language
      end

      def to_s
        text
      end
    end
  end
end
