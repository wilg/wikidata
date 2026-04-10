# frozen_string_literal: true

module Wikidata
  module DataValues
    class Globecoordinate < Wikidata::DataValues::Value
      def latitude
        data_hash.latitude
      end

      def longitude
        data_hash.longitude
      end

      def precision
        data_hash.precision
      end

      def globe_item_id
        data_hash.globe&.split("/")&.last
      end

      def to_h
        {latitude: latitude, longitude: longitude, precision: precision, globe: globe_item_id}
      end

      def to_s
        "#{latitude}, #{longitude}"
      end
    end
  end
end
