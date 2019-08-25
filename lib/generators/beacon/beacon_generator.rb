# frozen_string_literal: true

require 'rails/generators/base'

class BeaconGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  def create_beacon_file
    template 'beacon.rb.tt', File.join('app', 'beacons', class_path, "#{file_name}_beacon.rb")
  end

  def insert_inclusion_into_model_file
    inject_into_class "app/models/#{file_name}.rb", class_name do
      "  include Beaconable\n"
    end
  end
end
