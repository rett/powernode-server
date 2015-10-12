require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'csv'
require 'ipaddress'
require 'net/ssh'
require 'ostruct'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Powernode
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    # Add Bower components to assets path.
    config.assets.paths << Rails.root.join('vendor', 'assets', 'bower_components')
  end

  def self.config
    Rails.application.config
  end
end

begin
  config_file = Rails.root.join('config', 'config.yml')
  YAML::load(ERB.new(File.read(config_file)).result)[Rails.env].each do |k, v|
    Powernode.config.send("#{k}=", v)
  end
rescue
  puts "\nThe config file #{config_file} is missing.  Please see config/#{config_file}.example to create one."
end
