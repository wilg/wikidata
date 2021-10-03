module Wikidata
  module DataValues
    class Value < Wikidata::HashedObject
      def resolve!
      end

      def resolved
        resolve!
        self
      end
    end
  end
end
