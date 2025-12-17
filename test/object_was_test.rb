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

  def test_object_was_responds_to_column_methods
    assert @user_was.respond_to?(:first_name)
    assert @user_was.respond_to?(:email)
    assert @user_was.respond_to?(:id)
    assert @user_was.respond_to?(:created_at)
  end

  def test_object_was_for_new_record_has_nil_values
    new_user = User.new(first_name: 'Test', last_name: 'User', email: 'test@test.com')
    user_was = Beaconable::ObjectWas.new(new_user).call

    assert_nil user_was.first_name
    assert_nil user_was.created_at
    assert_nil user_was.id
  end

  def test_object_was_captures_all_columns
    # Ensure all model columns are captured
    column_names = User.column_names.map(&:to_sym)
    column_names.each do |column|
      assert @user_was.respond_to?(column),
             "object_was should respond to #{column}"
    end
  end

  def test_object_was_does_not_change_after_save
    original_first_name = @user_was.first_name  # 'John'

    # Even after the user is saved with new value, object_was should retain old value
    assert_equal 'John', original_first_name
    assert_equal 'Bruce', @user.first_name
  end
end
