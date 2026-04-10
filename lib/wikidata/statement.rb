# frozen_string_literal: true

module Wikidata
  class Statement < Wikidata::HashedObject
    def mainsnak
      @mainsnak ||= Wikidata::Snak.new(data_hash.mainsnak)
    end

    def rank
      data_hash["rank"]
    end

    def qualifiers
      @qualifiers ||= if data_hash.qualifiers
        data_hash.qualifiers.flat_map do |_property_id, snaks|
          snaks.map { |snak_hash| Wikidata::Snak.new(snak_hash) }
        end
      else
        []
      end
    end

    def qualifiers_for(property_id)
      qualifiers.select { |s| s.property_id == property_id }
    end

    def start_time
      qualifiers_for("P580").first&.value
    end

    def end_time
      qualifiers_for("P582").first&.value
    end

    def point_in_time
      qualifiers_for("P585").first&.value
    end

    def current?
      end_time.nil?
    end

    def references
      @references ||= if data_hash.references
        data_hash.references.map do |ref_hash|
          ref_hash["snaks"]&.flat_map do |_property_id, snaks|
            snaks.map { |snak_hash| Wikidata::Snak.new(snak_hash) }
          end || []
        end
      else
        []
      end
    end
  end
end
