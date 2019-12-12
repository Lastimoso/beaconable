# frozen_string_literal: true

require 'test_helper'

class BaseBeaconTest < Minitest::Test
  def setup
    setup_db
    @user = User.create(first_name: 'John',
                        last_name: 'Rambo',
                        email: 'john@rambo.com')
    @user_was = @user.dup
    @user_was.first_name = 'Peter'
  end

  def teardown
    teardown_db
  end

  def test_field_changed_returns_true_if_modified
    beacon = Beaconable::BaseBeacon.new(@user, @user_was)
    assert beacon.send(:field_changed?, :first_name)
  end

  def test_field_changed_returns_false_if_not_modified
    beacon = Beaconable::BaseBeacon.new(@user, @user_was)
    refute beacon.send(:field_changed?, :last_name)
  end

  def test_any_field_changed_returns_true_if_modified
    beacon = Beaconable::BaseBeacon.new(@user, @user_was)
    assert beacon.send(:any_field_changed?, :first_name, :last_name)
  end

  def test_any_field_changed_returns_false_if_not_modified
    beacon = Beaconable::BaseBeacon.new(@user, @user_was)
    refute beacon.send(:any_field_changed?, :last_name, :email)
  end

  def test_new_entry_returns_true
    @user_was = User.new(first_name: 'John',
                         last_name: 'Rambo',
                         email: 'rambo@gmail.com')
    @user = @user_was.dup
    @user.save
    beacon = Beaconable::BaseBeacon.new(@user, @user_was)
    assert beacon.send(:new_entry?), "new_entry? should return true if it's new"
  end

  def test_new_entry_returns_false
    @user_was = Beaconable::ObjectWas.new(@user).call
    beacon = Beaconable::BaseBeacon.new(@user, @user_was)
    refute beacon.send(:new_entry?), 'new_entry? should return false if existing'
  end

  def test_field_changed_from_to_returns_true
    @user_was.email = 'jack@bauer.com'
    beacon = Beaconable::BaseBeacon.new(@user, @user_was)
    refute beacon.send(:field_changed, :email).send(:from, 'john@rambo.com').send(:to, 'jack@bauer.com')
  end

  def test_field_changed_from_to_returns_false_if_no_change
    @user_was.email = @user.email
    beacon = Beaconable::BaseBeacon.new(@user, @user_was)
    refute beacon.send(:field_changed, :email).send(:from, 'john@rambo.com').send(:to, 'jack@bauer.com')
  end

  def test_field_changed_from_to_returns_false_if_from_is_false
    @user_was.email = 'jack@bauer.com'
    beacon = Beaconable::BaseBeacon.new(@user, @user_was)
    refute beacon.send(:field_changed, :email).send(:from, 'incorrect@rambo.com').send(:to, 'jack@bauer.com')
  end

  def test_field_changed_from_to_returns_false_if_to_is_false
    @user_was.email = 'jack@bauer.com'
    beacon = Beaconable::BaseBeacon.new(@user, @user_was)
    refute beacon.send(:field_changed, :email).send(:from, 'john@rambo.com').send(:to, 'incorrect@bauer.com')
  end
end
