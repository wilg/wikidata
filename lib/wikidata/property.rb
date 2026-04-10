# frozen_string_literal: true

module Wikidata
  class Property < Wikidata::Entity
    def datatype
      data_hash["datatype"]
    end
  end
end
