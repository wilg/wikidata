module Wikidata
  module DataValues
    class CommonsMedia < Wikidata::DataValues::Value

      def to_s
        data_hash.imagename
      end

    end
  end
end
