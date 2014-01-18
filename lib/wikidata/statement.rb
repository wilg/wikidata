module Wikidata
  class Statement < Wikidata::HashedObject

    def mainsnak
      @mainsnak ||= Wikidata::Snak.new(data_hash.mainsnak)
    end

  end
end
