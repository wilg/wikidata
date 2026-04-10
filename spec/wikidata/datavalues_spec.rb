require "spec_helper"

class DataValuesEntityTest < Minitest::Test
  def test_item_id
    val = Wikidata::DataValues::Entity.new("entity-type" => "item", "numeric-id" => 515)
    assert_equal "Q515", val.item_id
    assert_equal 515, val.numeric_id
    assert_equal "item", val.kind
  end

  def test_to_s_without_resolution
    val = Wikidata::DataValues::Entity.new("entity-type" => "item", "numeric-id" => 515)
    assert_equal "Q515", val.to_s
  end
end

class DataValuesTimeTest < Minitest::Test
  def test_to_time
    val = Wikidata::DataValues::Time.new("time" => "+1781-09-04T00:00:00Z", "precision" => 11)
    assert_equal 1781, val.to_time.year
    assert_equal 9, val.to_time.month
    assert_equal 4, val.to_time.day
  end

  def test_to_s
    val = Wikidata::DataValues::Time.new("time" => "+2024-01-15T00:00:00Z", "precision" => 11)
    assert_includes val.to_s, "2024"
  end
end

class DataValuesYearTest < Minitest::Test
  def test_to_i
    val = Wikidata::DataValues::Year.new("time" => "+2020-00-00T00:00:00Z", "precision" => 9)
    assert_equal 2020, val.to_i
  end

  def test_to_s
    val = Wikidata::DataValues::Year.new("time" => "+1900-00-00T00:00:00Z", "precision" => 9)
    assert_equal "1900", val.to_s
  end

  def test_bce_year
    # Current implementation splits on "-" so BCE years return 0
    # This documents existing behavior — proper BCE support tracked separately
    val = Wikidata::DataValues::Year.new("time" => "-0500-00-00T00:00:00Z", "precision" => 9)
    assert_equal 0, val.to_i
  end
end

class DataValuesGlobecoordinateTest < Minitest::Test
  def test_to_s
    val = Wikidata::DataValues::Globecoordinate.new(
      "latitude" => 34.05, "longitude" => -118.25,
      "precision" => 0.00027777777777778, "globe" => "http://www.wikidata.org/entity/Q2"
    )
    assert_equal "34.05, -118.25", val.to_s
  end
end

class DataValuesStringTest < Minitest::Test
  def test_to_s
    val = Wikidata::DataValues::String.new("string" => "https://example.com")
    assert_equal "https://example.com", val.to_s
  end
end

class DataValuesCommonsMediaTest < Minitest::Test
  def test_to_s
    val = Wikidata::DataValues::CommonsMedia.new("imagename" => "Example.jpg")
    assert_equal "Example.jpg", val.to_s
  end

  def test_url
    val = Wikidata::DataValues::CommonsMedia.new("imagename" => "Example.jpg")
    assert_includes val.url, "Special:Redirect/file/Example.jpg"
  end

  def test_url_with_width
    val = Wikidata::DataValues::CommonsMedia.new("imagename" => "Example.jpg")
    assert_includes val.url(width: 300), "width=300"
  end
end

class DataValuesQuantityTest < Minitest::Test
  def make_quantity(amount: "+3976322", unit: "http://www.wikidata.org/entity/Q11573", **extra)
    Wikidata::DataValues::Quantity.new({"amount" => amount, "unit" => unit}.merge(extra))
  end

  def test_amount
    assert_equal 3_976_322.0, make_quantity.amount
  end

  def test_amount_string_strips_plus
    assert_equal "3976322", make_quantity.amount_string
  end

  def test_amount_string_preserves_negative
    assert_equal "-5", make_quantity(amount: "-5").amount_string
  end

  def test_unit_item_id
    assert_equal "Q11573", make_quantity.unit_item_id
  end

  def test_unitless
    q = make_quantity(unit: "1")
    assert q.unitless?
    refute make_quantity.unitless?
  end

  def test_bounds
    q = Wikidata::DataValues::Quantity.new("amount" => "+100", "unit" => "1", "upperBound" => "+105", "lowerBound" => "+95")
    assert_equal 105.0, q.upper_bound
    assert_equal 95.0, q.lower_bound
  end

  def test_bounds_nil_when_absent
    assert_nil make_quantity.upper_bound
    assert_nil make_quantity.lower_bound
  end

  def test_to_h
    assert_equal({amount: "3976322", unit: "Q11573"}, make_quantity.to_h)
  end

  def test_to_s
    assert_equal "3976322", make_quantity.to_s
  end
end

class DataValuesSomeValueTest < Minitest::Test
  def test_to_s
    val = Wikidata::DataValues::SomeValue.new({})
    assert_equal "Unknown value", val.to_s
  end
end

class DataValuesNoValueTest < Minitest::Test
  def test_to_s
    val = Wikidata::DataValues::NoValue.new({})
    assert_equal "No value", val.to_s
  end
end
