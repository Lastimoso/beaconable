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
    assert SideEffect.find_by(name: 'new_first_name').success?, 'New first name should fire specific side-effect'
  end

  def test_new_last_name_should_not_fire_specific_sideeffect
    @user.update(last_name: 'Jack')
    assert SideEffect.find_by(name: 'new_first_name').nil?, 'New Last Name should not fire new_first_name side-effect'
  end
end
