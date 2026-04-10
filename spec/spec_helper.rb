require "minitest/autorun"
require "webmock/minitest"
require "json"
require "wikidata"

# Disable all real HTTP connections in tests
WebMock.disable_net_connect!

# Reset identity map and configuration between tests
module TestHelpers
  def setup
    Wikidata::IdentityMap.class_variable_set(:@@identity_map, {})
    super
  end

  def fixture_path(name)
    File.join(File.dirname(__FILE__), "fixtures", name)
  end

  def load_fixture(name)
    JSON.parse(File.read(fixture_path(name)))
  end

  def stub_wikidata_entity(id, entity_hash)
    response = {"entities" => {id => entity_hash}}
    stub_request(:get, /wikidata\.org\/w\/api\.php/)
      .with(query: hash_including("ids" => id))
      .to_return(status: 200, body: JSON.generate(response), headers: {"Content-Type" => "application/json"})
  end

  def stub_wikidata_search(query, item_titles)
    search_response = {
      "query" => {
        "search" => item_titles.map { |t| {"title" => t} }
      }
    }
    stub_request(:get, /wikidata\.org\/w\/api\.php/)
      .with(query: hash_including("action" => "query", "srsearch" => query))
      .to_return(status: 200, body: JSON.generate(search_response), headers: {"Content-Type" => "application/json"})
  end
end
