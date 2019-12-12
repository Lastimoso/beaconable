# frozen_string_literal: true

require 'test_helper'

class ObjectWasTest < Minitest::Test
  def setup
    setup_db
    @user = User.create(first_name: 'John',
                        last_name: 'Rambo',
                        email: 'john@rambo.com')
    @user.first_name = 'Bruce'
    @user_was = Beaconable::ObjectWas.new(@user).call
    @user.save!
  end

  def teardown
    teardown_db
  end

  def test_object_was_has_previous_field
    refute_equal @user.first_name, @user_was.first_name
    assert_equal 'Bruce', @user.first_name
    assert_equal 'John', @user_was.first_name
  end

  def test_object_was_keeps_other_fields
    assert_equal @user.last_name, @user_was.last_name
    assert_equal @user.email, @user_was.email
  end

  def test_object_was_has_id_and_timestamp
    assert_equal @user.id, @user_was.id
    assert_equal @user.created_at, @user_was.created_at
  end
end
