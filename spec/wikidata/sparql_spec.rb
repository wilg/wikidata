require "spec_helper"

class SparqlTest < Minitest::Test
  include TestHelpers

  SPARQL_URL = "https://query.wikidata.org/sparql"

  def stub_sparql(sparql, bindings)
    response = {"results" => {"bindings" => bindings}}
    stub_request(:get, SPARQL_URL)
      .with(query: hash_including("query" => sparql, "format" => "json"))
      .to_return(status: 200, body: JSON.generate(response), headers: {"Content-Type" => "application/json"})
  end

  def test_query_returns_bindings
    sparql = "SELECT ?item WHERE { ?item wdt:P31 wd:Q515 } LIMIT 2"
    bindings = [
      {"item" => {"type" => "uri", "value" => "http://www.wikidata.org/entity/Q65"}},
      {"item" => {"type" => "uri", "value" => "http://www.wikidata.org/entity/Q60"}}
    ]
    stub_sparql(sparql, bindings)

    results = Wikidata::Sparql.query(sparql)
    assert_equal 2, results.length
    assert_equal "http://www.wikidata.org/entity/Q65", results.first.dig("item", "value")
  end

  def test_item_ids_extracts_qids
    sparql = "SELECT ?item WHERE { ?item wdt:P31 wd:Q515 } LIMIT 2"
    bindings = [
      {"item" => {"type" => "uri", "value" => "http://www.wikidata.org/entity/Q65"}},
      {"item" => {"type" => "uri", "value" => "http://www.wikidata.org/entity/Q60"}}
    ]
    stub_sparql(sparql, bindings)

    ids = Wikidata::Sparql.item_ids(sparql)
    assert_equal ["Q65", "Q60"], ids
  end

  def test_items_returns_fetched_entities
    sparql = "SELECT ?item WHERE { ?item wdt:P31 wd:Q515 } LIMIT 1"
    bindings = [{"item" => {"type" => "uri", "value" => "http://www.wikidata.org/entity/Q65"}}]
    stub_sparql(sparql, bindings)
    stub_wikidata_entity("Q65", load_fixture("Q65.json"))

    items = Wikidata::Sparql.items(sparql)
    assert_equal 1, items.length
    assert_equal "Los Angeles", items.first.label
  end

  def test_query_raises_on_http_error
    VCR.turned_off do
      stub_request(:get, /query\.wikidata\.org\/sparql/)
        .to_return(status: 500)

      assert_raises(Wikidata::HttpError) do
        Wikidata::Sparql.query("SELECT ?x WHERE { ?x ?y ?z }")
      end
    end
  end

  def test_item_ids_with_custom_variable
    sparql = "SELECT ?city WHERE { ?city wdt:P31 wd:Q515 }"
    bindings = [{"city" => {"type" => "uri", "value" => "http://www.wikidata.org/entity/Q65"}}]
    stub_sparql(sparql, bindings)

    ids = Wikidata::Sparql.item_ids(sparql, variable: "city")
    assert_equal ["Q65"], ids
  end

  def test_items_returns_empty_for_no_results
    sparql = "SELECT ?item WHERE { ?item wdt:P31 wd:Q999999999 }"
    stub_sparql(sparql, [])

    items = Wikidata::Sparql.items(sparql)
    assert_equal [], items
  end
end
