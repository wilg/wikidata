require "spec_helper"

class IdentityMapTest < Minitest::Test
  include TestHelpers

  def test_cache_and_retrieve
    item = Wikidata::Item.new({"id" => "Q1", "labels" => {"en" => {"value" => "Universe"}}})
    Wikidata::IdentityMap.cache!("Q1", item)

    cached = Wikidata::IdentityMap.cached_value("Q1")
    assert_instance_of Wikidata::Item, cached
    assert_equal "Q1", cached.id
  end

  def test_returns_nil_for_uncached
    assert_nil Wikidata::IdentityMap.cached_value("Q_NOT_CACHED_#{rand(999999)}")
  end

  def test_if_uncached_returns_cached_value
    item = Wikidata::Item.new({"id" => "Q2", "labels" => {}})
    Wikidata::IdentityMap.cache!("Q2", item)

    result = Wikidata::IdentityMap.if_uncached("Q2") { raise "should not be called" }
    assert_equal "Q2", result.id
  end

  def test_if_uncached_calls_block_when_not_cached
    called = false
    Wikidata::IdentityMap.if_uncached("Q_MISSING_#{rand(999999)}") { called = true }
    assert called
  end
end
