require "spec_helper"

class LexemeTest < Minitest::Test
  include TestHelpers

  def lexeme
    @lexeme ||= Wikidata::Lexeme.new(load_fixture("L7.json"))
  end

  def test_id
    assert_equal "L7", lexeme.id
  end

  def test_lemma
    assert_equal "cat", lexeme.lemma
  end

  def test_all_lemmas
    assert_equal({"en" => "cat"}, lexeme.all_lemmas)
  end

  def test_language_item_id
    assert_equal "Q1860", lexeme.language_item_id
  end

  def test_lexical_category_item_id
    assert_equal "Q1084", lexeme.lexical_category_item_id
  end

  def test_claims
    assert lexeme.claims.length >= 1
    assert lexeme.claims.first.is_a?(Wikidata::Statement)
  end

  def test_forms
    assert_equal 2, lexeme.forms.length
    assert_instance_of Wikidata::Form, lexeme.forms.first
  end

  def test_form_representation
    assert_equal "cat", lexeme.forms.first.representation
  end

  def test_form_all_representations
    assert_equal({"en" => "cat"}, lexeme.forms.first.all_representations)
  end

  def test_form_plural
    plural = lexeme.forms.find { |f| f.form_id == "L7-F5" }
    assert_equal "cats", plural.representation
  end

  def test_form_grammatical_features
    assert_equal ["Q110786"], lexeme.forms.first.grammatical_features
  end

  def test_senses
    assert_equal 2, lexeme.senses.length
    assert_instance_of Wikidata::Sense, lexeme.senses.first
  end

  def test_sense_gloss
    assert_equal "domesticated subspecies of feline animal", lexeme.senses.first.gloss
  end

  def test_sense_all_glosses
    glosses = lexeme.senses.first.all_glosses
    assert_equal "domesticated subspecies of feline animal", glosses["en"]
    assert_equal "gato doméstico", glosses["es"]
  end

  def test_sense_claims
    sense = lexeme.senses.first
    assert sense.claims.length >= 1
    assert_equal "P5137", sense.claims.first.mainsnak.property_id
  end

  def test_inspect
    assert_includes lexeme.inspect, "L7"
    assert_includes lexeme.inspect, "cat"
  end

  def test_find_by_id_returns_lexeme
    response = {"entities" => {"L7" => load_fixture("L7.json")}}
    stub_request(:get, /wikidata\.org\/w\/api\.php/)
      .with(query: hash_including("ids" => "L7"))
      .to_return(status: 200, body: JSON.generate(response), headers: {"Content-Type" => "application/json"})

    # Disable REST API for this test since it doesn't handle lexemes
    original = Wikidata::Configuration.use_rest_api
    Wikidata::Configuration.use_rest_api = false

    entity = Wikidata::Entity.find_by_id("L7")
    assert_instance_of Wikidata::Lexeme, entity
    assert_equal "cat", entity.lemma
  ensure
    Wikidata::Configuration.use_rest_api = original
  end
end
