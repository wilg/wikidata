# frozen_string_literal: true

module Wikidata
  module DataValues
    class NoValue < Wikidata::DataValues::Value
      def to_s
        "No value"
      end
    end
  end
end
