# frozen_string_literal: true

module Beaconable
  # Immutable snapshot of an ActiveRecord object's attributes at a point in time.
  # Replaces OpenStruct for better performance and explicit immutability.
  class AttributeSnapshot
    def initialize(attributes)
      @attributes = attributes.freeze
    end

    def method_missing(method_name, *args)
      key = method_name.to_sym
      return @attributes[key] if @attributes.key?(key)

      super
    end

    def respond_to_missing?(method_name, include_private = false)
      @attributes.key?(method_name.to_sym) || super
    end

    # Direct hash-style access for attribute values
    def [](key)
      @attributes[key.to_sym]
    end

    # Returns a copy of the attributes hash (for debugging/inspection)
    def to_h
      @attributes.dup
    end

    def inspect
      "#<#{self.class.name} #{@attributes.inspect}>"
    end
  end
end
