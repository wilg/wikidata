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

  def test_start_time
    preferred_leader = item.ranked_claims_for_property_id("P6").first
    assert_instance_of Wikidata::DataValues::Time, preferred_leader.start_time
    assert_equal 2022, preferred_leader.start_time.to_time.year
  end

  def test_end_time
    # The normal-rank former mayor has an end_time
    all_leaders = item.claims_for_property_id("P6")
    former = all_leaders.find { |c| c.rank == "normal" }
    assert_instance_of Wikidata::DataValues::Time, former.end_time
    assert_equal 2022, former.end_time.to_time.year
  end

  def test_current
    preferred_leader = item.ranked_claims_for_property_id("P6").first
    assert preferred_leader.current?

    all_leaders = item.claims_for_property_id("P6")
    former = all_leaders.find { |c| c.rank == "normal" }
    refute former.current?
  end

  def test_point_in_time_nil_when_absent
    assert_nil inception_claim.point_in_time
  end
end
