require "spec_helper"

class SnakTest < Minitest::Test
  def make_snak(hash)
    Wikidata::Snak.new(hash)
  end

  def test_property_id
    snak = make_snak("snaktype" => "value", "property" => "P31", "datavalue" => {
      "value" => {"entity-type" => "item", "numeric-id" => 515},
      "type" => "wikibase-entityid"
    })
    assert_equal "P31", snak.property_id
  end

  def test_entity_value
    snak = make_snak("snaktype" => "value", "property" => "P31", "datavalue" => {
      "value" => {"entity-type" => "item", "numeric-id" => 515},
      "type" => "wikibase-entityid"
    })
    assert_instance_of Wikidata::DataValues::Entity, snak.value
    assert_equal "Q515", snak.value.item_id
    assert_equal "item", snak.value.kind
    assert_equal 515, snak.value.numeric_id
  end

  def test_time_value_day_precision
    snak = make_snak("snaktype" => "value", "property" => "P571", "datavalue" => {
      "value" => {
        "time" => "+1781-09-04T00:00:00Z", "timezone" => 0,
        "before" => 0, "after" => 0, "precision" => 11,
        "calendarmodel" => "http://www.wikidata.org/entity/Q1985727"
      },
      "type" => "time"
    })
    assert_instance_of Wikidata::DataValues::Time, snak.value
    assert_equal 1781, snak.value.to_time.year
    assert_equal 9, snak.value.to_time.month
    assert_equal 4, snak.value.to_time.day
  end

  def test_time_value_year_precision
    snak = make_snak("snaktype" => "value", "property" => "P585", "datavalue" => {
      "value" => {
        "time" => "+2020-00-00T00:00:00Z", "timezone" => 0,
        "before" => 0, "after" => 0, "precision" => 9,
        "calendarmodel" => "http://www.wikidata.org/entity/Q1985727"
      },
      "type" => "time"
    })
    assert_instance_of Wikidata::DataValues::Year, snak.value
    assert_equal 2020, snak.value.to_i
    assert_equal "2020", snak.value.to_s
  end

  def test_globecoordinate_value
    snak = make_snak("snaktype" => "value", "property" => "P625", "datavalue" => {
      "value" => {
        "latitude" => 34.05, "longitude" => -118.25,
        "altitude" => nil, "precision" => 0.00027777777777778,
        "globe" => "http://www.wikidata.org/entity/Q2"
      },
      "type" => "globecoordinate"
    })
    assert_instance_of Wikidata::DataValues::Globecoordinate, snak.value
    assert_equal "34.05, -118.25", snak.value.to_s
  end

  def test_string_value
    snak = make_snak("snaktype" => "value", "property" => "P856", "datatype" => "url", "datavalue" => {
      "value" => "https://www.lacity.org/",
      "type" => "string"
    })
    assert_instance_of Wikidata::DataValues::String, snak.value
    assert_equal "https://www.lacity.org/", snak.value.to_s
  end

  def test_commons_media_value
    snak = make_snak("snaktype" => "value", "property" => "P18", "datatype" => "commonsMedia", "datavalue" => {
      "value" => "LA Skyline Mountains2.jpg",
      "type" => "string"
    })
    assert_instance_of Wikidata::DataValues::CommonsMedia, snak.value
    assert_equal "LA Skyline Mountains2.jpg", snak.value.to_s
    assert_includes snak.value.url, "LA+Skyline+Mountains2.jpg"
  end

  def test_novalue_returns_no_value_object
    snak = make_snak("snaktype" => "novalue", "property" => "P40")
    assert_instance_of Wikidata::DataValues::NoValue, snak.value
    assert_equal "No value", snak.value.to_s
  end

  def test_somevalue_returns_some_value_object
    snak = make_snak("snaktype" => "somevalue", "property" => "P1082")
    assert_instance_of Wikidata::DataValues::SomeValue, snak.value
    assert_equal "Unknown value", snak.value.to_s
  end

  def test_no_value_predicate
    novalue_snak = make_snak("snaktype" => "novalue", "property" => "P40")
    assert novalue_snak.no_value?

    value_snak = make_snak("snaktype" => "value", "property" => "P31", "datavalue" => {
      "value" => {"entity-type" => "item", "numeric-id" => 515},
      "type" => "wikibase-entityid"
    })
    refute value_snak.no_value?
  end

  def test_some_value_predicate
    somevalue_snak = make_snak("snaktype" => "somevalue", "property" => "P1082")
    assert somevalue_snak.some_value?

    value_snak = make_snak("snaktype" => "value", "property" => "P31", "datavalue" => {
      "value" => {"entity-type" => "item", "numeric-id" => 515},
      "type" => "wikibase-entityid"
    })
    refute value_snak.some_value?
  end

  def test_unknown_predicate
    novalue_snak = make_snak("snaktype" => "novalue", "property" => "P40")
    assert novalue_snak.unknown?

    somevalue_snak = make_snak("snaktype" => "somevalue", "property" => "P1082")
    assert somevalue_snak.unknown?

    value_snak = make_snak("snaktype" => "value", "property" => "P31", "datavalue" => {
      "value" => {"entity-type" => "item", "numeric-id" => 515},
      "type" => "wikibase-entityid"
    })
    refute value_snak.unknown?
  end

  def test_nil_datavalue_returns_nil
    snak = make_snak("snaktype" => "value", "property" => "P999", "datavalue" => nil)
    assert_nil snak.value
  end

  def test_quantity_value
    snak = make_snak("snaktype" => "value", "property" => "P1082", "datavalue" => {
      "value" => {"amount" => "+3976322", "unit" => "http://www.wikidata.org/entity/Q11573"},
      "type" => "quantity"
    })
    assert_instance_of Wikidata::DataValues::Quantity, snak.value
    assert_equal 3_976_322.0, snak.value.amount
    assert_equal "Q11573", snak.value.unit_item_id
    assert_equal "3976322", snak.value.to_s
  end

  def test_quantity_value_dimensionless
    snak = make_snak("snaktype" => "value", "property" => "P1082", "datavalue" => {
      "value" => {"amount" => "+1000", "unit" => "1"},
      "type" => "quantity"
    })
    assert_instance_of Wikidata::DataValues::Quantity, snak.value
    assert_equal 1000.0, snak.value.amount
    assert_equal "1", snak.value.unit_item_id
  end

  def test_monolingualtext_value
    snak = make_snak("snaktype" => "value", "property" => "P1559", "datavalue" => {
      "value" => {"text" => "Los Angeles", "language" => "en"},
      "type" => "monolingualtext"
    })
    assert_instance_of Wikidata::DataValues::MonolingualText, snak.value
    assert_equal "Los Angeles", snak.value.text
    assert_equal "en", snak.value.language
    assert_equal "Los Angeles", snak.value.to_s
  end

  def test_time_value_month_precision
    snak = make_snak("snaktype" => "value", "property" => "P585", "datavalue" => {
      "value" => {
        "time" => "+2020-03-00T00:00:00Z", "timezone" => 0,
        "before" => 0, "after" => 0, "precision" => 10,
        "calendarmodel" => "http://www.wikidata.org/entity/Q1985727"
      },
      "type" => "time"
    })
    assert_instance_of Wikidata::DataValues::Year, snak.value
    assert_equal 2020, snak.value.to_i
  end

  def test_time_value_century_precision
    snak = make_snak("snaktype" => "value", "property" => "P585", "datavalue" => {
      "value" => {
        "time" => "+1800-00-00T00:00:00Z", "timezone" => 0,
        "before" => 0, "after" => 0, "precision" => 7,
        "calendarmodel" => "http://www.wikidata.org/entity/Q1985727"
      },
      "type" => "time"
    })
    assert_instance_of Wikidata::DataValues::Year, snak.value
    assert_equal 1800, snak.value.to_i
  end

  def test_custom_value_handler
    Wikidata::Snak.register_value_handler("custom-test") { |dv, _snak| dv.value }

    snak = make_snak("snaktype" => "value", "property" => "P999", "datavalue" => {
      "value" => "custom_result",
      "type" => "custom-test"
    })
    assert_equal "custom_result", snak.value
  ensure
    Wikidata::Snak.value_handlers.delete("custom-test")
  end

  def test_inspect
    snak = make_snak("snaktype" => "value", "property" => "P31", "datavalue" => {
      "value" => {"entity-type" => "item", "numeric-id" => 515},
      "type" => "wikibase-entityid"
    })
    assert_includes snak.inspect, "P31"
    assert_includes snak.inspect, "Snak"
  end
end
