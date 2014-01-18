module Wikidata
  class Statement < Wikidata::Entity

    def mainsnak
      @mainsnak ||= Wikidata::Snak.new(hash.mainsnak)
    end

  end
end
