# frozen_string_literal: true

require 'json'
require 'optparse'

require 'blueprint_to_swift/core_ext/ostruct/deconstruct'

require 'blueprint_to_swift/application'
require 'blueprint_to_swift/ast/any'
require 'blueprint_to_swift/ast/api'
require 'blueprint_to_swift/ast/array'
require 'blueprint_to_swift/ast/data_structure'
require 'blueprint_to_swift/ast/data_structure_group'
require 'blueprint_to_swift/ast/deferred_type'
require 'blueprint_to_swift/ast/http_transaction'
require 'blueprint_to_swift/ast/member'
require 'blueprint_to_swift/ast/object'
require 'blueprint_to_swift/ast/request'
require 'blueprint_to_swift/ast/resource'
require 'blueprint_to_swift/ast/resource_group'
require 'blueprint_to_swift/ast/response'
require 'blueprint_to_swift/drafter_json_parser'
require 'blueprint_to_swift/version'

module BlueprintToSwift
  class Error < StandardError
  end

  def self.root
    @root ||= File.expand_path(File.join(File.dirname(__FILE__), '..'))
  end
end
