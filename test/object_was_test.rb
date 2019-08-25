# frozen_string_literal: true

require 'test_helper'

class ObjectWasTest < Minitest::Test
  def setup
    setup_db
    @user = User.create(first_name: 'John', last_name: 'Rambo', email: 'rambo@gmail.com')
  end

  def teardown
    teardown_db
  end

  def test_creates_object_was_successfully
    @user.first_name = 'Bruce'
    user_was = Beaconable::ObjectWas.new(@user).call
    @user.save!
    assert @user.first_name != user_was.first_name, 'first_name should be different'
    assert_equal 'Bruce', @user.first_name
    assert_equal 'John', user_was.first_name
  end
end