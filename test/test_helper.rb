$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require "minitest/autorun"
require "minitest/spec"
require "minitest/reporters"
require "active_support"
require "active_record"
require "beaconable"

Minitest::Reporters.use!

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

class User < ActiveRecord::Base
  include Beaconable
end

class SideEffect < ActiveRecord::Base
end

class UserBeacon < Beaconable::BaseBeacon

  alias user object
  alias user_was object_was

  def call
    SideEffect.create(name: 'default', success: true)
    test_field_changed
  end

  private

  def test_field_changed
    SideEffect.create(name: 'new_first_name', success: true) if field_changed?(:first_name)
  end
end

def setup_db
  ActiveRecord::Migration.suppress_messages do
    ActiveRecord::Schema.define(:version => 1) do
      create_table :users do |t|
        t.string :email, :limit => 255, :null => false
        t.string :first_name, :limit => 100, :null => true
        t.string :last_name, :limit => 100, :null => true
      end
      create_table :side_effects do |t|
        t.string :name, limit: 255, null: false
        t.boolean :success, default: false
      end
    end
  end
end

def teardown_db
  ActiveRecord::Migration.suppress_messages do
    ActiveRecord::Base.connection.tables.each do |table|
      ActiveRecord::Base.connection.drop_table(table)
    end
  end
end
