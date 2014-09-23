module Wikidata
  module DataValues
    class CommonsMedia < Wikidata::DataValues::Value

      def to_s
        data_hash.imagename
      end

      def resolve!
        query = {image: data_hash.imagename, thumbwidth: 150}
        puts "Getting: #{query}".yellow if Wikidata.verbose?
        r = Faraday.get('http://tools.wmflabs.org/magnus-toolserver/commonsapi.php', query)
        @data_hash = Hashie::Mash.new(r.body['response'].merge({imagename: data_hash.imagename}))
      end

      def url
        resolved.file.urls.file
      end

    end
  end
end
