# frozen_string_literal: true

require 'beaconable/version'
require 'beaconable/object_was'
require 'beaconable/base_beacon'
require 'active_record'

module Beaconable
  extend ActiveSupport::Concern
  included do
    attr_accessor :beacon_metadata
    attr_accessor :skip_beacon

    before_save :save_for_beacon, unless: :skip_beacon
    before_destroy :save_for_beacon, unless: :skip_beacon
    after_touch :save_for_beacon, unless: :skip_beacon
    after_commit :fire_beacon, unless: :skip_beacon
  end

  private

  def save_for_beacon
    @object_was ||= ObjectWas.new(self).call
  end

  def fire_beacon
    "#{self.class.name}Beacon".constantize.new(self, @object_was).call
    @object_was = nil
    self.beacon_metadata = nil
  end
end
