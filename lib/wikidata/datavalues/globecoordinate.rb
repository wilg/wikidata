module Wikidata
  module DataValues
    class Globecoordinate < Wikidata::DataValues::Value
      def to_s
        "#{latitude}, #{longitude}"
      end
    end
  end
end
