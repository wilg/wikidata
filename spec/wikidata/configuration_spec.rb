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

  def test_maxlag_included_in_queries
    original = Wikidata::Configuration.maxlag
    Wikidata::Configuration.maxlag = 5

    params = Wikidata::Entity.default_query_params
    assert_equal 5, params[:maxlag]
  ensure
    Wikidata::Configuration.maxlag = original
  end

  def test_maxlag_omitted_when_nil
    original = Wikidata::Configuration.maxlag
    Wikidata::Configuration.maxlag = nil

    params = Wikidata::Entity.default_query_params
    refute params.key?(:maxlag)
  ensure
    Wikidata::Configuration.maxlag = original
  end

  def test_default_logger
    assert_instance_of Logger, Wikidata::Configuration.logger
  end

  def test_custom_logger
    custom = Logger.new(StringIO.new)
    original = Wikidata::Configuration.logger
    Wikidata.logger = custom
    assert_equal custom, Wikidata.logger
  ensure
    Wikidata.logger = original
  end

  def test_verbose_logs_to_logger
    output = StringIO.new
    custom = Logger.new(output, level: Logger::DEBUG)
    original_logger = Wikidata::Configuration.logger
    original_verbose = Wikidata::Configuration.verbose
    Wikidata.logger = custom
    Wikidata::Configuration.verbose = true

    stub_request(:get, /wikidata\.org\/w\/api\.php/)
      .with(query: hash_including("ids" => "Q1"))
      .to_return(status: 200, body: '{"entities":{"Q1":{"id":"Q1"}}}', headers: {"Content-Type" => "application/json"})

    Wikidata::Item.find_all_by_id("Q1")
    assert_includes output.string, "[Wikidata]"
  ensure
    Wikidata.logger = original_logger
    Wikidata::Configuration.verbose = original_verbose
  end
end
