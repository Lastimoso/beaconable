# frozen_string_literal: true

module Beaconable
  class BaseBeacon
    attr_reader :object, :object_was

    def initialize(object, object_was)
      @object = object
      @object_was = object_was
    end

    private

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
