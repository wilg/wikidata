# frozen_string_literal: true

module Wikidata
  module DataValues
    class Year < Wikidata::DataValues::Value
      def to_i
        time_str = data_hash.time.to_s
        # Wikidata times have a mandatory sign prefix: "+1952-..." or "-0500-..."
        if time_str.start_with?("-")
          -time_str[1..].split("-").first.to_i
        else
          time_str.sub(/\A\+/, "").split("-").first.to_i
        end
      end

      def bce?
        to_i < 0
      end

      def precision
        data_hash.precision.to_i
      end

      def to_s
        year = to_i
        if year < 0
          "#{-year} BCE"
        else
          year.to_s
        end
      end
    end
  end
end
