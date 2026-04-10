require "spec_helper"

class ItemTest < Minitest::Test
  include TestHelpers

  def la_item
    @la_item ||= Wikidata::Item.new(load_fixture("Q65.json"))
  end

  def test_id
    assert_equal "Q65", la_item.id
  end

  def test_label
    assert_equal "Los Angeles", la_item.label
  end

  def test_description
    assert_equal "city in California, United States", la_item.description
  end

  def test_claims_returns_all_claims
    assert_instance_of Array, la_item.claims
    assert la_item.claims.length > 0
    assert la_item.claims.all? { |c| c.is_a?(Wikidata::Statement) }
  end

  def test_claims_for_property_id
    coords = la_item.claims_for_property_id("P625")
    assert_equal 1, coords.length
    assert_equal "P625", coords.first.mainsnak.property_id
  end

  def test_claims_for_property_id_returns_empty_for_missing
    assert_equal [], la_item.claims_for_property_id("P99999")
  end

  def test_ranked_claims_prefers_preferred_rank
    leaders = la_item.ranked_claims_for_property_id("P6")
    assert_equal 1, leaders.length
    assert_equal "preferred", leaders.first.data_hash["rank"]
    assert_equal "Q380900", leaders.first.mainsnak.value.item_id
  end

  def test_ranked_claims_excludes_deprecated
    # Remove preferred claims to test normal vs deprecated filtering
    item_data = load_fixture("Q65.json")
    item_data["claims"]["P6"].reject! { |c| c["rank"] == "preferred" }
    item = Wikidata::Item.new(item_data)

    leaders = item.ranked_claims_for_property_id("P6")
    assert_equal 1, leaders.length
    assert_equal "normal", leaders.first.data_hash["rank"]
  end

  def test_claims_with_no_claims_hash
    item = Wikidata::Item.new({"id" => "Q1", "labels" => {}, "claims" => nil})
    assert_equal [], item.claims
  end

  def test_best_value_for
    val = la_item.best_value_for("P625")
    assert_instance_of Wikidata::DataValues::Globecoordinate, val
  end

  def test_best_value_for_respects_rank
    val = la_item.best_value_for("P6")
    assert_instance_of Wikidata::DataValues::Entity, val
    assert_equal "Q380900", val.item_id
  end

  def test_best_value_for_missing_property
    assert_nil la_item.best_value_for("P99999")
  end

  def test_values_for
    vals = la_item.values_for("P6")
    # preferred rank only (1 claim)
    assert_equal 1, vals.length
  end

  def test_values_for_with_limit
    item_data = load_fixture("Q65.json")
    # Remove preferred so we get normal claims
    item_data["claims"]["P6"].reject! { |c| c["rank"] == "preferred" }
    item = Wikidata::Item.new(item_data)

    vals = item.values_for("P6", limit: 1)
    assert_equal 1, vals.length
  end

  def test_values_for_missing_property
    assert_equal [], la_item.values_for("P99999")
  end

  def test_image
    img = la_item.image
    assert_instance_of Wikidata::DataValues::CommonsMedia, img
    assert_equal "LA Skyline Mountains2.jpg", img.to_s
  end

  def test_websites
    sites = la_item.websites
    assert_equal ["https://www.lacity.org/"], sites
  end

  def test_aliases
    assert_equal ["LA", "City of Los Angeles"], la_item.aliases
  end

  def test_aliases_empty_for_missing_locale
    assert_equal [], la_item.aliases(:fr)
  end

  def test_sitelinks
    refute_nil la_item.sitelinks
    assert_equal "Los Angeles", la_item.sitelinks.enwiki.title
  end

  def test_sitelink
    link = la_item.sitelink("enwiki")
    assert_equal "Los Angeles", link.title
    assert_equal "enwiki", link.site
  end

  def test_sitelink_missing
    assert_nil la_item.sitelink("nonexistent")
  end

  def test_inspect
    assert_includes la_item.inspect, "Q65"
    assert_includes la_item.inspect, "Los Angeles"
  end
end
