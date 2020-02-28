#!/usr/bin/env ruby

require 'json'
require 'yaml'

a = JSON.parse(File.read('/Users/doob/development/ruby/blueprint_to_swift/spec/data/deferred_type.json'))
File.write('deferred_type.yml', YAML.dump(a))
