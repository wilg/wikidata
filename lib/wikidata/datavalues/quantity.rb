module Wikidata
  module DataValues
    class Quantity < Wikidata::DataValues::Value
      def amount
        data_hash.amount.to_f
      end

      def unit_item_id
        data_hash.unit&.split("/")&.last
      end

      def to_s
        amount.to_s
      end
    end
  end
end
