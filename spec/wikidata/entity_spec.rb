require "spec_helper"

class EntityTest < Minitest::Test
  include TestHelpers

  def test_find_by_id
    VCR.use_cassette("find_by_id_Q65") do
      item = Wikidata::Item.find_by_id("Q65")
      assert_instance_of Wikidata::Item, item
      assert_equal "Q65", item.id
      assert_equal "Los Angeles", item.label
    end
  end

  def test_find_by_id_caches_result
    VCR.use_cassette("find_by_id_Q65") do
      first = Wikidata::Item.find_by_id("Q65")
      second = Wikidata::Item.find_by_id("Q65")
      assert_equal first.id, second.id
    end
  end

  def test_find_by_title_returns_nil_for_missing
    VCR.use_cassette("find_by_title_not_found") do
      result = Wikidata::Item.find_by_title("Xyzzy_Nonexistent_Page_12345")
      assert_nil result
    end
  end

  def test_find_all_by_id_returns_array
    VCR.use_cassette("find_by_id_Q65") do
      items = Wikidata::Item.find_all_by_id("Q65")
      assert_instance_of Array, items
      assert_equal 1, items.length
    end
  end

  def test_find_by_title
    VCR.use_cassette("find_by_title_Los_Angeles") do
      item = Wikidata::Item.find_by_title("Los Angeles")
      assert_instance_of Wikidata::Item, item
      assert_equal "Los Angeles", item.label
    end
  end

  def test_search
    VCR.use_cassette("search_Los_Angeles") do
      results = Wikidata::Item.search("Los Angeles")
      assert_instance_of Array, results
      assert results.length >= 1
      assert_equal "Los Angeles", results.first.label
    end
  end

  def test_search_with_limit
    stub_wikidata_search("test_query", ["Q1", "Q2", "Q3"])
    # Stub the batch entity fetch that search triggers
    response = {"entities" => {
      "Q1" => {"id" => "Q1", "labels" => {"en" => {"value" => "A"}}},
      "Q2" => {"id" => "Q2", "labels" => {"en" => {"value" => "B"}}},
      "Q3" => {"id" => "Q3", "labels" => {"en" => {"value" => "C"}}}
    }}
    stub_request(:get, /wikidata\.org\/w\/api\.php/)
      .with(query: hash_including("ids" => "Q1|Q2|Q3"))
      .to_return(status: 200, body: JSON.generate(response), headers: {"Content-Type" => "application/json"})

    results = Wikidata::Item.search("test_query", limit: 3)
    assert_equal 3, results.length
  end

  def test_search_returns_empty_on_no_results
    VCR.use_cassette("search_no_results") do
      results = Wikidata::Item.search("xyzzy_totally_nonexistent_query_12345")
      assert_equal [], results
    end
  end

  def test_raises_http_error_on_server_failure
    stub_request(:get, /wikidata\.org\/w\/api\.php/)
      .with(query: hash_including("ids" => "Q00"))
      .to_return(status: 500)

    err = assert_raises(Wikidata::HttpError) do
      Wikidata::Item.find_all_by_id("Q00")
    end
    assert_equal 500, err.status
    assert_includes err.message, "HTTP 500"
  end

  def test_raises_http_error_on_search_failure
    stub_request(:get, /wikidata\.org\/w\/api\.php/)
      .with(query: hash_including("action" => "query", "srsearch" => "test"))
      .to_return(status: 503)

    err = assert_raises(Wikidata::HttpError) do
      Wikidata::Item.search("test")
    end
    assert_equal 503, err.status
  end

  def test_find_by_property_value
    stub_wikidata_search("haswbstatement:P646=/m/0181lj", ["Q65"])
    stub_wikidata_entity("Q65", load_fixture("Q65.json"))

    item = Wikidata::Item.find_by_property_value("P646", "/m/0181lj")
    assert_instance_of Wikidata::Item, item
    assert_equal "Q65", item.id
  end

  def test_find_all_by_property_value
    stub_wikidata_search("haswbstatement:P345=tt0111161", ["Q65"])
    stub_wikidata_entity("Q65", load_fixture("Q65.json"))

    results = Wikidata::Item.find_all_by_property_value("P345", "tt0111161")
    assert_instance_of Array, results
    assert_equal 1, results.length
  end

  def test_find_by_property_value_returns_nil_when_not_found
    stub_wikidata_search("haswbstatement:P646=/m/nonexistent", [])

    result = Wikidata::Item.find_by_property_value("P646", "/m/nonexistent")
    assert_nil result
  end

  def test_find_by_property_value_resolves_preset
    original_presets = Wikidata::Configuration.property_presets.dup
    Wikidata::Configuration.property_presets[:freebase_id] = "P646"

    stub_wikidata_search("haswbstatement:P646=/m/0181lj", ["Q65"])
    stub_wikidata_entity("Q65", load_fixture("Q65.json"))

    item = Wikidata::Item.find_by_property_value(:freebase_id, "/m/0181lj")
    assert_instance_of Wikidata::Item, item
    assert_equal "Q65", item.id
  ensure
    Wikidata::Configuration.property_presets = original_presets
  end

  def test_redirected_entity_cached_under_both_ids
    # Simulate a redirect: request Q999 but the entity's real id is Q65
    redirected_entity = load_fixture("Q65.json")
    response = {"entities" => {"Q999" => redirected_entity}}
    stub_request(:get, /wikidata\.org\/w\/api\.php/)
      .with(query: hash_including("ids" => "Q999"))
      .to_return(status: 200, body: JSON.generate(response), headers: {"Content-Type" => "application/json"})

    items = Wikidata::Item.find_all_by_id("Q999")
    assert_equal 1, items.length
    assert_equal "Q65", items.first.id

    # Both IDs should resolve from cache
    assert_equal "Q65", Wikidata::IdentityMap.cached_value("Q999").id
    assert_equal "Q65", Wikidata::IdentityMap.cached_value("Q65").id
  end

  def test_raises_rate_limit_error_on_429
    stub_request(:get, /wikidata\.org\/w\/api\.php/)
      .with(query: hash_including("ids" => "Q42"))
      .to_return(status: 429, headers: {"Retry-After" => "1"})

    original = Wikidata::Configuration.max_retries
    Wikidata::Configuration.max_retries = 0

    err = assert_raises(Wikidata::RateLimitError) do
      Wikidata::Item.find_all_by_id("Q42")
    end
    assert_equal 429, err.status
    assert_equal 1, err.retry_after
  ensure
    Wikidata::Configuration.max_retries = original
  end

  def test_retries_on_429
    call_count = 0
    stub_request(:get, /wikidata\.org\/w\/api\.php/)
      .with(query: hash_including("ids" => "Q42"))
      .to_return do
        call_count += 1
        if call_count == 1
          {status: 429, headers: {"Retry-After" => "0"}}
        else
          {status: 200, body: JSON.generate({"entities" => {"Q42" => {"id" => "Q42"}}}), headers: {"Content-Type" => "application/json"}}
        end
      end

    items = Wikidata::Item.find_all_by_id("Q42")
    assert_equal 1, items.length
    assert_equal 2, call_count
  end

  def test_redirected_entity
    entity_hash = load_fixture("Q65.json").merge(
      "redirects" => {"from" => "Q999", "to" => "Q65"}
    )
    item = Wikidata::Item.new(entity_hash)
    assert item.redirected?
    assert_equal "Q999", item.redirected_from
  end

  def test_non_redirected_entity
    item = Wikidata::Item.new(load_fixture("Q65.json"))
    refute item.redirected?
    assert_nil item.redirected_from
  end

  def test_client_is_faraday_connection
    client = Wikidata::Entity.client
    assert_instance_of Faraday::Connection, client
  end

  def test_client_sends_user_agent
    client = Wikidata::Entity.client
    assert_includes client.headers["User-Agent"], "wikidata-ruby/"
  end

  def test_custom_user_agent
    original = Wikidata::Configuration.user_agent
    Wikidata::Configuration.user_agent = "MyApp/1.0"
    client = Wikidata::Entity.client
    assert_equal "MyApp/1.0", client.headers["User-Agent"]
  ensure
    Wikidata::Configuration.user_agent = original
  end
end
