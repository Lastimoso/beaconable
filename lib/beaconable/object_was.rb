# frozen_string_literal: true

module Beaconable
  class ObjectWas
    attr_reader :object

    def initialize(object)
      @object = object
    end

    def call
      hashed_object = {}
      symbolized_column_names = object.class.column_names.map {|column_name| column_name.to_sym}
      symbolized_column_names.each do |column_name|
        hashed_object[column_name] = object.send("#{column_name}_was")
      end
      OpenStruct.new(hashed_object)
    end
  end
end
