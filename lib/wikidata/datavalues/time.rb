# frozen_string_literal: true

module Wikidata
  module DataValues
    class Time < Wikidata::DataValues::Value
      def to_time
        # Wikidata times have a mandatory sign prefix (+/-) that DateTime.parse
        # may not handle correctly. Strip it for positive dates.
        time_str = data_hash.time.to_s.sub(/\A\+/, "")
        DateTime.parse(time_str)
      end

      def precision
        data_hash.precision.to_i
      end

      def calendar_model
        data_hash.calendarmodel
      end

      def julian?
        calendar_model&.include?("Q1985786")
      end

      def to_s
        str = to_time.strftime("%Y-%m-%d")
        str += " (Julian)" if julian?
        str
      end
    end
  end
end
