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

  def test_object_creation_fire_beacon
    User.create(first_name: 'Jack', last_name: 'Bauer', email: 'bauer@gmail.com')
    assert SideEffect.find_by(name: 'default').success?
  end

  def test_new_first_name_should_fire_specific_sideeffect
    @user.update(first_name: 'Jack')
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

end
