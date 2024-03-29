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
end
