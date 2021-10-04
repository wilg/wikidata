module Wikidata
  module DataValues
    class CommonsMedia < Wikidata::DataValues::Value
      def to_s
        data_hash.imagename
      end

      def url(width: nil)
        "https://commons.wikimedia.org/w/index.php?title=Special:Redirect/file/#{CGI.escape(data_hash.imagename)}&width=#{width || ""}"
      end
    end
  end
end
