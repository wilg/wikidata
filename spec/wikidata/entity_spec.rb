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

  def test_search_returns_empty_on_no_results
    VCR.use_cassette("search_no_results") do
      results = Wikidata::Item.search("xyzzy_totally_nonexistent_query_12345")
      assert_equal [], results
    end
  end

  def test_handles_http_error
    stub_request(:get, /wikidata\.org\/w\/api\.php/)
      .with(query: hash_including("ids" => "Q00"))
      .to_return(status: 500)

    results = Wikidata::Item.find_all_by_id("Q00")
    assert_equal [], results
  end
end
