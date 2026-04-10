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

  def test_reset_clears_cache
    item = Wikidata::Item.new({"id" => "Q3", "labels" => {}})
    Wikidata::IdentityMap.cache!("Q3", item)
    Wikidata::IdentityMap.reset!
    assert_nil Wikidata::IdentityMap.cached_value("Q3")
  end

  def test_ttl_expires_entries
    original_ttl = Wikidata::Configuration.cache_ttl
    Wikidata::Configuration.cache_ttl = 0.001 # 1ms

    item = Wikidata::Item.new({"id" => "Q4", "labels" => {}})
    Wikidata::IdentityMap.cache!("Q4", item)
    sleep 0.01
    assert_nil Wikidata::IdentityMap.cached_value("Q4")
  ensure
    Wikidata::Configuration.cache_ttl = original_ttl
  end

  def test_ttl_keeps_fresh_entries
    original_ttl = Wikidata::Configuration.cache_ttl
    Wikidata::Configuration.cache_ttl = 3600

    item = Wikidata::Item.new({"id" => "Q5", "labels" => {}})
    Wikidata::IdentityMap.cache!("Q5", item)
    assert_equal "Q5", Wikidata::IdentityMap.cached_value("Q5").id
  ensure
    Wikidata::Configuration.cache_ttl = original_ttl
  end
end
