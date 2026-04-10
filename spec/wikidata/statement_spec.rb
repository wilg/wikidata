require "spec_helper"

class StatementTest < Minitest::Test
  include TestHelpers

  def item
    @item ||= Wikidata::Item.new(load_fixture("Q65.json"))
  end

  def inception_claim
    item.claims_for_property_id("P571").first
  end

  def test_rank
    assert_equal "normal", inception_claim.rank
    preferred = item.ranked_claims_for_property_id("P6").first
    assert_equal "preferred", preferred.rank
  end

  def test_qualifiers
    quals = inception_claim.qualifiers
    assert_instance_of Array, quals
    assert_equal 1, quals.length
    assert_instance_of Wikidata::Snak, quals.first
    assert_equal "P459", quals.first.property_id
  end

  def test_qualifiers_for
    quals = inception_claim.qualifiers_for("P459")
    assert_equal 1, quals.length
    assert_equal "Q39825", quals.first.value.item_id
  end

  def test_qualifiers_for_missing
    assert_equal [], inception_claim.qualifiers_for("P999")
  end

  def test_qualifiers_empty_when_absent
    url_claim = item.claims_for_property_id("P856").first
    assert_equal [], url_claim.qualifiers
  end

  def test_references
    refs = inception_claim.references
    assert_instance_of Array, refs
    assert_equal 1, refs.length
    assert_instance_of Array, refs.first
    assert_equal "P248", refs.first.first.property_id
    assert_equal "Q36578", refs.first.first.value.item_id
  end

  def test_references_empty_when_absent
    url_claim = item.claims_for_property_id("P856").first
    assert_equal [], url_claim.references
  end
end
