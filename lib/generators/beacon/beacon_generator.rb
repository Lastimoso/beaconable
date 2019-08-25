# frozen_string_literal: true

require 'rails/generators/base'

class BeaconGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  def create_serializer_file
    template 'beacon.rb.tt', File.join('app', 'beacons', class_path, "#{file_name}_beacon.rb")
  end
end
