require "spec_helper"

class PropertyTest < Minitest::Test
  def test_datatype
    prop = Wikidata::Property.new({"id" => "P31", "datatype" => "wikibase-item", "labels" => {}})
    assert_equal "wikibase-item", prop.datatype
  end

  def test_datatype_nil_when_absent
    prop = Wikidata::Property.new({"id" => "P31", "labels" => {}})
    assert_nil prop.datatype
  end

  def test_inherits_entity_methods
    prop = Wikidata::Property.new({"id" => "P31", "labels" => {"en" => {"value" => "instance of"}}, "datatype" => "wikibase-item"})
    assert_equal "P31", prop.id
    assert_equal "instance of", prop.label
  end
end
