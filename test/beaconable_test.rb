# frozen_string_literal: true

require 'test_helper'

class BeaconableTest < Minitest::Test
  def setup
    setup_db
    @user = User.create(first_name: 'John', last_name: 'Rambo', email: 'john@rambo.com')
    SideEffect.destroy_all
  end

  def teardown
    teardown_db
  end

  def test_that_it_has_a_version_number
    refute_nil ::Beaconable::VERSION
  end

  def test_object_destruction_fire_beacon
    @user.destroy
    assert SideEffect.find_by(name: 'destroyed_user').success?
  end

  def test_object_creation_fire_beacon
    User.create(first_name: 'Jack', last_name: 'Bauer', email: 'bauer@gmail.com')
    assert SideEffect.find_by(name: 'default').success?
  end

  def test_new_first_name_should_fire_specific_sideeffect
    ActiveRecord::Base.transaction do
      @user.update(first_name: 'Jack')
      @user.update(last_name: 'Roger')
    end
    assert SideEffect.find_by(name: 'new_first_name').success?,
           'New first name should fire specific side-effect'
  end

  def test_new_last_name_should_not_fire_specific_sideeffect
    @user.update(last_name: 'Jack')
    assert SideEffect.find_by(name: 'new_first_name').nil?,
           'New Last Name should not fire new_first_name side-effect'
  end

  def test_chained_methods_should_fire_specific_sideeffect
    @user.update(email: 'peter@parker.com')
    assert SideEffect.find_by(name: 'nested_conditions').success?,
           'It should fire side-effect if every condition is met'
  end

  def test_chained_methods_should_not_fire_sideeffect_if_from_false
    @user = User.create(first_name: 'John', last_name: 'Wick', email: 'john@wick.com')
    SideEffect.destroy_all

    @user.update(email: 'peter@parker.com')
    assert SideEffect.find_by(name: 'nested_conditions').nil?,
           'It should not fire side-effect if from is false'
  end

  def test_chained_methods_should_not_fire_sideeffect_if_to_false
    @user.update(email: 'jack@bauer.com')
    assert SideEffect.find_by(name: 'nested_conditions').nil?,
           'It should not fire side-effect if to is false'
  end

  def test_no_beacon_fired_if_skip_beacon_is_true
    user = User.new(first_name: 'Jack', last_name: 'Bauer', email: 'bauer@gmail.com')
    user.skip_beacon = true
    user.save!

    assert_nil SideEffect.find_by(name: 'default')
  end

  def test_beacon_metadata_is_set_at_the_instance_and_available_at_the_beacon
    user = User.new(first_name: 'Jack', last_name: 'Bauer', email: 'bauer@gmail.com')
    user.beacon_metadata = { source: 'api' }
    user.save!
    side_effect = SideEffect.find_by(name: 'default')

    assert_equal 'api', side_effect.source
  end

  def test_beacon_metadata_should_be_cleared_after_the_beacon_is_fired
    user = User.new(first_name: 'Jack', last_name: 'Bauer', email: 'bauer@gmail.com')
    user.beacon_metadata = { source: 'api' }
    user.save!

    assert_nil user.beacon_metadata
  end

  # Critical test: multiple saves in a transaction should capture the FIRST state
  def test_multiple_saves_in_transaction_captures_first_state
    # @user.first_name is 'John' at this point
    ActiveRecord::Base.transaction do
      @user.update!(first_name: 'Changed1')
      @user.update!(first_name: 'Changed2')
      @user.update!(first_name: 'Changed3')
    end

    # The beacon should see the change from original 'John', not intermediate values
    # This is verified by the 'new_first_name' side effect being created
    assert SideEffect.exists?(name: 'new_first_name'),
           'Multiple saves in transaction should detect change from original state'
  end

  def test_multiple_different_field_changes_in_transaction
    # Original: first_name='John', email='john@rambo.com'
    ActiveRecord::Base.transaction do
      @user.update!(first_name: 'Changed')
      @user.update!(email: 'peter@parker.com') # This matches the chained condition
    end

    assert SideEffect.exists?(name: 'new_first_name'),
           'Should detect first_name changed from original'
    assert SideEffect.exists?(name: 'nested_conditions'),
           'Should detect email changed from john@rambo.com to peter@parker.com'
  end

  def test_touch_fires_beacon
    SideEffect.destroy_all
    @user.touch
    assert SideEffect.exists?(name: 'default'),
           'Touch should fire the beacon'
  end

  def test_skip_beacon_on_update
    SideEffect.destroy_all
    @user.skip_beacon = true
    @user.update!(first_name: 'Skipped')

    refute SideEffect.exists?(name: 'new_first_name'),
           'Update with skip_beacon should not fire beacon'
  end

  def test_skip_beacon_on_destroy
    SideEffect.destroy_all
    @user.skip_beacon = true
    @user.destroy

    refute SideEffect.exists?(name: 'destroyed_user'),
           'Destroy with skip_beacon should not fire beacon'
  end
end
