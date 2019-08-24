# frozen_string_literal: true

require 'beaconable/version'
require 'beaconable/object_was'

module Beaconable
  extend ActiveSupport::Concern
  included do
    before_save :save_for_beacon
    after_commit :fire_beacon
  end

  private

  def save_for_beacon
    @object_was = ObjectWas.new(self).call
  end

  def fire_beacon
    if self.saved_changes?
      "#{self.class.name}Beacon".constantize.new(self, @object_was).call
    end
  end
end
