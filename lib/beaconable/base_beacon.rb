# frozen_string_literal: true

module Beaconable
  class BaseBeacon
    attr_reader :object, :object_was, :beacon_metadata

    def initialize(object, object_was)
      @object = object
      @object_was = object_was
      @beacon_metadata = object.beacon_metadata
    end

    def field_changed(field)
      @field = field
      @result = field_changed? field
      self
    end

    def from(*values)
      return self unless @result

      @result = values.include? object_was.send(@field)
      self
    end

    def to(*values)
      @result && values.include?(object.send(@field))
    end

    private

    def destroyed_entry?
      object.destroyed?
    end

    def field_changed?(field)
      object.send(field) != object_was.send(field)
    end

    def any_field_changed?(*fields)
      fields.each do |field|
        return true if field_changed?(field)
      end
      false
    end

    def new_entry?
      object_was.created_at.nil?
    end
  end
end
