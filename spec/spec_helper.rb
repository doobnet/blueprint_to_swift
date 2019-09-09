# frozen_string_literal: true

require 'bundler/setup'

require 'pry'
require 'blueprint_to_swift'

Dir[File.join(BlueprintToSwift.root, 'spec/support/**/*.rb')].each { require @1 }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'
  config.order = :random

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
