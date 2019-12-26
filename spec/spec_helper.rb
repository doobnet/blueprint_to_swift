# frozen_string_literal: true

require 'bundler/setup'

require 'awesome_print'
require 'pry'
require 'pry-rescue/rspec'

require 'blueprint_to_swift'

AwesomePrint.pry!

Dir[File.join(BlueprintToSwift.root, 'spec/support/**/*.rb')].each { require _1 }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'
  config.order = :random

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
