# frozen_string_literal: true

require 'test_helper'

class AttributeSnapshotTest < Minitest::Test
  def setup
    @snapshot = Beaconable::AttributeSnapshot.new({
                                                    name: 'John',
                                                    age: 30,
                                                    active: true,
                                                    score: nil
                                                  })
  end

  def test_method_access
    assert_equal 'John', @snapshot.name
    assert_equal 30, @snapshot.age
    assert_equal true, @snapshot.active
  end

  def test_bracket_access_with_symbol
    assert_equal 'John', @snapshot[:name]
    assert_equal 30, @snapshot[:age]
  end

  def test_bracket_access_with_string
    assert_equal 'John', @snapshot['name']
    assert_equal 30, @snapshot['age']
  end

  def test_respond_to_for_existing_attributes
    assert @snapshot.respond_to?(:name)
    assert @snapshot.respond_to?(:age)
    assert @snapshot.respond_to?(:active)
  end

  def test_respond_to_for_missing_attributes
    refute @snapshot.respond_to?(:nonexistent)
    refute @snapshot.respond_to?(:missing_field)
  end

  def test_raises_for_unknown_method
    assert_raises(NoMethodError) { @snapshot.nonexistent }
  end

  def test_to_h_returns_hash_copy
    hash = @snapshot.to_h
    assert_instance_of Hash, hash
    assert_equal({ name: 'John', age: 30, active: true, score: nil }, hash)
  end

  def test_to_h_returns_unfrozen_copy
    hash = @snapshot.to_h
    hash[:name] = 'Modified' # Should not raise
    assert_equal 'Modified', hash[:name]
    assert_equal 'John', @snapshot.name # Original unchanged
  end

  def test_inspect_output
    result = @snapshot.inspect
    assert_includes result, 'AttributeSnapshot'
    assert_includes result, 'name'
    assert_includes result, 'John'
  end

  def test_nil_values_are_preserved
    assert_nil @snapshot.score
    assert @snapshot.respond_to?(:score)
  end

  def test_empty_snapshot
    empty = Beaconable::AttributeSnapshot.new({})
    refute empty.respond_to?(:anything)
    assert_raises(NoMethodError) { empty.anything }
  end
end
