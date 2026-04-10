require "spec_helper"

class ConfigurationTest < Minitest::Test
  def test_default_property_presets
    presets = Wikidata::Configuration.property_presets
    assert_equal "P25", presets[:mother]
    assert_equal "P22", presets[:father]
    assert_equal "P31", presets[:instance_of]
    assert_equal "P279", presets[:subclass_of]
  end

  def test_configure_block
    original_verbose = Wikidata::Configuration.verbose
    Wikidata.configure { |c| c.verbose = true }
    assert Wikidata.verbose?
  ensure
    Wikidata::Configuration.verbose = original_verbose
  end

  def test_default_cache_ttl
    assert_equal 3600, Wikidata::Configuration.cache_ttl
  end

  def test_default_faraday_adapter
    assert_equal :net_http, Wikidata::Configuration.faraday_adapter
  end

  def test_use_only_default_language
    assert Wikidata::Configuration.use_only_default_language
    assert Wikidata.use_only_default_language?
  end

  def test_default_languages_hash
    hash = Wikidata.default_languages_hash
    assert hash.key?(:languages)
  end
end
