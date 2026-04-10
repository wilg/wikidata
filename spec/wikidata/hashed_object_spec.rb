require "spec_helper"

class HashedObjectTest < Minitest::Test
  def test_data_hash_access
    obj = Wikidata::HashedObject.new("foo" => "bar", "count" => 42)
    assert_equal "bar", obj.foo
    assert_equal 42, obj.count
  end

  def test_method_missing_for_missing_key
    obj = Wikidata::HashedObject.new("foo" => "bar")
    assert_raises(NoMethodError) { obj.nonexistent }
  end

  def test_respond_to_missing
    obj = Wikidata::HashedObject.new("foo" => "bar")
    assert obj.respond_to?(:foo)
    refute obj.respond_to?(:nonexistent)
  end

  def test_nested_hash_access
    obj = Wikidata::HashedObject.new("nested" => {"name" => "value"})
    assert_equal "value", obj.nested.name
  end
end
