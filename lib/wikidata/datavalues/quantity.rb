# frozen_string_literal: true

module Wikidata
  module DataValues
    class Quantity < Wikidata::DataValues::Value
      def amount
        data_hash.amount.to_f
      end

      def amount_string
        data_hash.amount.to_s.sub(/\A\+/, "")
      end

      def unit_item_id
        data_hash.unit&.split("/")&.last
      end

      def unitless?
        unit_item_id == "1"
      end

      def upper_bound
        data_hash.upperBound&.to_f
      end

      def lower_bound
        data_hash.lowerBound&.to_f
      end

      def to_h
        {amount: amount_string, unit: unit_item_id}
      end

      def to_s
        amount_string
      end
    end
  end
end
