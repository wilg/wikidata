require "spec_helper"

class RestClientTest < Minitest::Test
  include TestHelpers

  REST_URL = "https://www.wikidata.org/w/rest.php/wikibase/v1/entities/items/Q42"

  def setup
    super
    Wikidata::RestClient.reset_client!
    VCR.turn_off!
    WebMock.reset!
  end

  def teardown
    VCR.turn_on!
    super
  end

  def stub_rest_item(status: 200, body: nil, etag: nil, headers: {})
    h = {"Content-Type" => "application/json"}.merge(headers)
    h["etag"] = etag if etag
    opts = {status: status, headers: h}
    opts[:body] = JSON.generate(body) if body
    stub_request(:get, REST_URL).to_return(opts)
  end

  def minimal_rest_response
    {
      "type" => "item",
      "id" => "Q42",
      "labels" => {"en" => "Douglas Adams"},
      "descriptions" => {"en" => "English writer"},
      "aliases" => {"en" => ["DNA", "Douglas Noel Adams"]},
      "statements" => {
        "P31" => [
          {
            "id" => "Q42$1",
            "rank" => "normal",
            "property" => {"id" => "P31", "data_type" => "wikibase-item"},
            "value" => {"type" => "value", "content" => "Q5"},
            "qualifiers" => [],
            "references" => []
          }
        ],
        "P569" => [
          {
            "id" => "Q42$2",
            "rank" => "normal",
            "property" => {"id" => "P569", "data_type" => "time"},
            "value" => {
              "type" => "value",
              "content" => {
                "time" => "+1952-03-11T00:00:00Z",
                "precision" => 11,
                "calendarmodel" => "http://www.wikidata.org/entity/Q1985727"
              }
            },
            "qualifiers" => [],
            "references" => []
          }
        ]
      },
      "sitelinks" => {
        "enwiki" => {"title" => "Douglas Adams", "badges" => [], "url" => "https://en.wikipedia.org/wiki/Douglas_Adams"}
      }
    }
  end

  def test_fetch_item_returns_normalized_data
    stub_rest_item(body: minimal_rest_response, etag: '"abc123"')

    result, etag = Wikidata::RestClient.fetch_item("Q42")
    assert_equal "Q42", result["id"]
    assert_equal '"abc123"', etag

    # Labels normalized to Action API format
    assert_equal "Douglas Adams", result.dig("labels", "en", "value")
    assert_equal "en", result.dig("labels", "en", "language")

    # Descriptions normalized
    assert_equal "English writer", result.dig("descriptions", "en", "value")

    # Aliases normalized
    assert_equal "DNA", result.dig("aliases", "en", 0, "value")

    # Claims normalized from statements
    claim = result.dig("claims", "P31", 0)
    assert_equal "value", claim.dig("mainsnak", "snaktype")
    assert_equal "P31", claim.dig("mainsnak", "property")
    assert_equal "wikibase-entityid", claim.dig("mainsnak", "datavalue", "type")
    assert_equal 5, claim.dig("mainsnak", "datavalue", "value", "numeric-id")

    # Time value normalized
    time_claim = result.dig("claims", "P569", 0)
    assert_equal "+1952-03-11T00:00:00Z", time_claim.dig("mainsnak", "datavalue", "value", "time")

    # Sitelinks normalized
    assert_equal "enwiki", result.dig("sitelinks", "enwiki", "site")
    assert_equal "Douglas Adams", result.dig("sitelinks", "enwiki", "title")
  end

  def test_fetch_item_returns_nil_on_304
    stub_request(:get, REST_URL)
      .with(headers: {"If-None-Match" => '"abc123"'})
      .to_return(status: 304)

    result = Wikidata::RestClient.fetch_item("Q42", etag: '"abc123"')
    assert_nil result
  end

  def test_fetch_item_raises_on_error
    stub_rest_item(status: 500)

    assert_raises(Wikidata::HttpError) do
      Wikidata::RestClient.fetch_item("Q42")
    end
  end

  def test_normalized_entity_works_with_item_class
    stub_rest_item(body: minimal_rest_response, etag: '"abc"')

    result, _etag = Wikidata::RestClient.fetch_item("Q42")
    item = Wikidata::Item.new(result)

    assert_equal "Q42", item.id
    assert_equal "Douglas Adams", item.label
    assert_equal "English writer", item.description
    assert_equal ["DNA", "Douglas Noel Adams"], item.aliases
    assert_equal "Douglas Adams", item.sitelink("enwiki").title

    # Claims work
    assert item.claims.length >= 1
    entity_val = item.best_value_for("P31")
    assert_instance_of Wikidata::DataValues::Entity, entity_val
    assert_equal "Q5", entity_val.item_id

    time_val = item.best_value_for("P569")
    assert_instance_of Wikidata::DataValues::Time, time_val
    assert_equal 1952, time_val.to_time.year
  end

  def test_string_value_normalization
    rest_data = {
      "type" => "item", "id" => "Q42",
      "labels" => {}, "descriptions" => {},
      "statements" => {
        "P856" => [{
          "id" => "Q42$3", "rank" => "normal",
          "property" => {"id" => "P856", "data_type" => "url"},
          "value" => {"type" => "value", "content" => "https://example.com"},
          "qualifiers" => [], "references" => []
        }]
      }
    }
    stub_rest_item(body: rest_data)

    result, _ = Wikidata::RestClient.fetch_item("Q42")
    item = Wikidata::Item.new(result)
    assert_instance_of Wikidata::DataValues::String, item.best_value_for("P856")
    assert_equal "https://example.com", item.best_value_for("P856").to_s
  end

  def test_somevalue_normalization
    rest_data = {
      "type" => "item", "id" => "Q42",
      "labels" => {}, "descriptions" => {},
      "statements" => {
        "P569" => [{
          "id" => "Q42$4", "rank" => "normal",
          "property" => {"id" => "P569", "data_type" => "time"},
          "value" => {"type" => "somevalue"},
          "qualifiers" => [], "references" => []
        }]
      }
    }
    stub_rest_item(body: rest_data)

    result, _ = Wikidata::RestClient.fetch_item("Q42")
    item = Wikidata::Item.new(result)
    assert_instance_of Wikidata::DataValues::SomeValue, item.best_value_for("P569")
  end
end

class RestApiIntegrationTest < Minitest::Test
  include TestHelpers

  def setup
    super
    Wikidata::RestClient.reset_client!
    VCR.turn_off!
    WebMock.reset!
  end

  def teardown
    VCR.turn_on!
    super
  end

  def test_find_by_id_uses_rest_api_and_caches_etag
    rest_data = {
      "type" => "item", "id" => "Q99",
      "labels" => {"en" => "Test"}, "descriptions" => {},
      "statements" => {}, "sitelinks" => {}
    }
    stub_request(:get, /rest\.php.*Q99/)
      .to_return(status: 200, body: JSON.generate(rest_data),
        headers: {"Content-Type" => "application/json", "etag" => '"etag1"'})

    item = Wikidata::Item.find_by_id("Q99")
    assert_equal "Q99", item.id
    assert_equal "Test", item.label

    # ETag should be stored
    assert_equal '"etag1"', Wikidata::IdentityMap.etag_for("Q99")
  end

  def test_find_by_id_returns_cached_on_304
    # First fetch
    rest_data = {
      "type" => "item", "id" => "Q98",
      "labels" => {"en" => "Cached"}, "descriptions" => {},
      "statements" => {}, "sitelinks" => {}
    }
    stub_request(:get, /rest\.php.*Q98/)
      .to_return(status: 200, body: JSON.generate(rest_data),
        headers: {"Content-Type" => "application/json", "etag" => '"etag2"'})

    item1 = Wikidata::Item.find_by_id("Q98")
    assert_equal "Cached", item1.label

    # Expire the cache so find_by_id doesn't return from fresh cache
    Wikidata::IdentityMap.instance_variable_get(:@mutex).synchronize do
      entry = Wikidata::IdentityMap.instance_variable_get(:@identity_map)["Q98"]
      entry.expires_at = Time.now - 1
    end

    # Second fetch — REST API returns 304
    stub_request(:get, /rest\.php.*Q98/)
      .with(headers: {"If-None-Match" => '"etag2"'})
      .to_return(status: 304)

    item2 = Wikidata::Item.find_by_id("Q98")
    assert_equal "Cached", item2.label
  end

  def test_find_by_id_uses_action_api_when_rest_disabled
    original = Wikidata::Configuration.use_rest_api
    Wikidata::Configuration.use_rest_api = false

    stub_request(:get, /wikidata\.org\/w\/api\.php/)
      .with(query: hash_including("ids" => "Q97"))
      .to_return(status: 200, body: JSON.generate({"entities" => {"Q97" => {"id" => "Q97", "labels" => {"en" => {"language" => "en", "value" => "Action API"}}}}}),
        headers: {"Content-Type" => "application/json"})

    item = Wikidata::Item.find_by_id("Q97")
    assert_equal "Action API", item.label
  ensure
    Wikidata::Configuration.use_rest_api = original
  end
end
