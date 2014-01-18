module Wikidata
  module DataValues
    class Time < Wikidata::DataValues::Value

      def to_time
        DateTime.parse(data_hash.time)
      end

      def to_s
        to_time.iso8601
      end

    end
  end
end
