# frozen_string_literal: true

module Beaconable
  # Captures the database state of an ActiveRecord object before changes.
  # Used to track what changed during a save/transaction.
  class ObjectWas
    attr_reader :object

    def initialize(object)
      @object = object
    end

    # Captures the current database state and returns an immutable snapshot.
    # For new records, returns a snapshot with nil values for all columns.
    def call
      AttributeSnapshot.new(build_attributes)
    end

    private

    def build_attributes
      if object.new_record?
        build_new_record_attributes
      else
        build_persisted_record_attributes
      end
    end

    # For new records, all "was" values are nil
    # This preserves backward compatibility with new_entry? detection
    def build_new_record_attributes
      object.class.column_names.each_with_object({}) do |column, hash|
        hash[column.to_sym] = nil
      end
    end

    # For persisted records, capture database values before current changes
    # Uses modern Rails 7+ dirty tracking API
    def build_persisted_record_attributes
      # Start with current attributes (which equal DB values for unchanged attrs)
      result = object.attributes.symbolize_keys
      # Replace changed attributes with their original database values
      object.changes_to_save.each do |attr, (old_value, _new_value)|
        result[attr.to_sym] = old_value
      end
      result
    end
  end
end
