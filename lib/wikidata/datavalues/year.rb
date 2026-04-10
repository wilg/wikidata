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
        to_i <= 0
      end

      # Wikidata uses astronomical year numbering where year 0 = 1 BCE,
      # year -1 = 2 BCE, etc. This returns the conventional BCE/CE year.
      def historical_year
        y = to_i
        (y <= 0) ? (1 - y) : y
      end

      def precision
        data_hash.precision.to_i
      end

      def month
        return nil if precision < 10
        time_str = data_hash.time.to_s.sub(/\A[+-]/, "")
        parts = time_str.split("-")
        parts[1]&.to_i
      end

      def to_s
        hy = historical_year
        suffix = bce? ? " BCE" : ""

        case precision
        when 6 # millennium
          m = ((hy - 1) / 1000) + 1
          "#{ordinalize(m)} millennium#{suffix}"
        when 7 # century
          c = ((hy - 1) / 100) + 1
          "#{ordinalize(c)} century#{suffix}"
        when 8 # decade
          "#{(hy / 10) * 10}s#{suffix}"
        when 10 # month
          if month && month > 0
            date = Date.new(2000, month, 1)
            "#{date.strftime("%B")} #{hy}#{suffix}"
          else
            "#{hy}#{suffix}"
          end
        else
          "#{hy}#{suffix}"
        end
      end

      private

      def ordinalize(n)
        suffix = if (11..13).cover?(n % 100)
          "th"
        else
          case n % 10
          when 1 then "st"
          when 2 then "nd"
          when 3 then "rd"
          else "th"
          end
        end
        "#{n}#{suffix}"
      end
    end
  end
end
