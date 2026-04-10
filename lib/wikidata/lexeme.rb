# frozen_string_literal: true

module Wikidata
  class Lexeme < Wikidata::Entity
    def lemma(locale = I18n.default_locale)
      delocalize data_hash.lemmas, locale
    end

    def all_lemmas
      return {} unless data_hash.lemmas
      data_hash.lemmas.each_with_object({}) do |(locale, entry), hash|
        hash[locale] = entry.value
      end
    end

    def language_item_id
      data_hash.language
    end

    def lexical_category_item_id
      data_hash.lexicalCategory
    end

    def forms
      @forms ||= (data_hash.forms || []).map { |f| Form.new(f) }
    end

    def senses
      @senses ||= (data_hash.senses || []).map { |s| Sense.new(s) }
    end

    def claims
      @claims ||= if data_hash.claims
        data_hash.claims.flat_map do |_property_id, statement_array|
          statement_array.map { |sh| Wikidata::Statement.new(sh) }
        end
      else
        []
      end
    end

    def self.search(term, language: "en", limit: 10)
      query = {
        action: "wbsearchentities",
        search: term,
        language: language,
        type: "lexeme",
        limit: limit,
        format: "json"
      }.merge(default_query_params)

      response = get "", query
      unless response.status == 200
        raise Wikidata::HttpError.new(response.status, response.env.url.to_s)
      end

      results = response.body["search"]
      return [] if results.nil? || results.empty?
      find_all_by_id(results.map { |r| r["id"] }.join("|"))
    end

    def inspect
      "<#{self.class} id=#{id} lemma=#{lemma.inspect}>"
    end
  end

  class Form < Wikidata::HashedObject
    def form_id
      data_hash.id
    end

    def representation(locale = I18n.default_locale)
      h = data_hash.representations&.dig(locale.to_s)
      h&.value
    end

    def all_representations
      return {} unless data_hash.representations
      data_hash.representations.each_with_object({}) do |(locale, entry), hash|
        hash[locale] = entry.value
      end
    end

    def grammatical_features
      data_hash.grammaticalFeatures || []
    end

    def claims
      @claims ||= if data_hash.claims
        data_hash.claims.flat_map do |_pid, stmts|
          stmts.map { |sh| Wikidata::Statement.new(sh) }
        end
      else
        []
      end
    end

    def inspect
      "<#{self.class} id=#{form_id} representation=#{representation.inspect}>"
    end
  end

  class Sense < Wikidata::HashedObject
    def sense_id
      data_hash.id
    end

    def gloss(locale = I18n.default_locale)
      h = data_hash.glosses&.dig(locale.to_s)
      h&.value
    end

    def all_glosses
      return {} unless data_hash.glosses
      data_hash.glosses.each_with_object({}) do |(locale, entry), hash|
        hash[locale] = entry.value
      end
    end

    def claims
      @claims ||= if data_hash.claims
        data_hash.claims.flat_map do |_pid, stmts|
          stmts.map { |sh| Wikidata::Statement.new(sh) }
        end
      else
        []
      end
    end

    def inspect
      "<#{self.class} id=#{sense_id} gloss=#{gloss.inspect}>"
    end
  end
end
