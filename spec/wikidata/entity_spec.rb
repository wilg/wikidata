require "spec_helper"

class EntityTest < Minitest::Test
  include TestHelpers

  def test_find_by_id
    fixture = load_fixture("Q65.json")
    stub_wikidata_entity("Q65", fixture)

    item = Wikidata::Item.find_by_id("Q65")
    assert_instance_of Wikidata::Item, item
    assert_equal "Q65", item.id
    assert_equal "Los Angeles", item.label
  end

  def test_find_by_id_caches_result
    fixture = load_fixture("Q65.json")
    stub = stub_wikidata_entity("Q65", fixture)

    Wikidata::Item.find_by_id("Q65")
    Wikidata::Item.find_by_id("Q65")

    assert_requested(stub, times: 1)
  end

  def test_find_by_id_returns_nil_for_missing
    response = {"entities" => {"-1" => {"id" => "-1"}}}
    stub_request(:get, /wikidata\.org\/w\/api\.php/)
      .with(query: hash_including("ids" => "Q99999999"))
      .to_return(status: 200, body: JSON.generate(response), headers: {"Content-Type" => "application/json"})

    result = Wikidata::Item.find_by_id("Q99999999")
    assert_nil result
  end

  def test_find_all_by_id_returns_array
    fixture = load_fixture("Q65.json")
    stub_wikidata_entity("Q65", fixture)

    items = Wikidata::Item.find_all_by_id("Q65")
    assert_instance_of Array, items
    assert_equal 1, items.length
  end

  def test_find_by_title
    fixture = load_fixture("Q65.json")
    response = {"entities" => {"Q65" => fixture}}
    stub_request(:get, /wikidata\.org\/w\/api\.php/)
      .with(query: hash_including("titles" => "Los Angeles"))
      .to_return(status: 200, body: JSON.generate(response), headers: {"Content-Type" => "application/json"})

    item = Wikidata::Item.find_by_title("Los Angeles")
    assert_instance_of Wikidata::Item, item
    assert_equal "Los Angeles", item.label
  end

  def test_search
    fixture = load_fixture("Q65.json")
    stub_wikidata_search("Los Angeles", ["Q65"])
    stub_wikidata_entity("Q65", fixture)

    results = Wikidata::Item.search("Los Angeles")
    assert_instance_of Array, results
    assert_equal 1, results.length
    assert_equal "Los Angeles", results.first.label
  end

  def test_search_returns_empty_on_no_results
    stub_request(:get, /wikidata\.org\/w\/api\.php/)
      .with(query: hash_including("action" => "query", "srsearch" => "xyznonexistent"))
      .to_return(status: 200, body: JSON.generate({"query" => {"search" => []}}), headers: {"Content-Type" => "application/json"})

    results = Wikidata::Item.search("xyznonexistent")
    assert_equal [], results
  end

  def test_handles_http_error
    stub_request(:get, /wikidata\.org\/w\/api\.php/)
      .with(query: hash_including("ids" => "Q65"))
      .to_return(status: 500)

    results = Wikidata::Item.find_all_by_id("Q65")
    assert_equal [], results
  end
end
