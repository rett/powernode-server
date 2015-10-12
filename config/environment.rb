# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

APP_VERSION = `git describe --always`.chomp unless defined? APP_VERSION
