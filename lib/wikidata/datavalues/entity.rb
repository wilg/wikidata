module Wikidata
  module DataValues
    class Entity < Wikidata::DataValues::Value
      def kind
        data_hash["entity-type"]
      end

      def numeric_id
        data_hash["numeric-id"]
      end

      def item_id
        "Q#{numeric_id}"
      end

      def entity
        if kind == "item"
          @item ||= Wikidata::Item.find_by_id(item_id)
        else
          raise "Unknown entity type"
        end
      end

      def resolve!
        entity
      end

      def to_s
        if @item.nil?
          item_id
        else
          "#{@item.label} (#{item_id})"
        end
      end
    end
  end
end
