# frozen_string_literal: true

module BlueprintToSwift
  module Ast
    class Api
      attr_accessor :resource_groups

      def initialize(resource_groups)
        @resource_groups = resource_groups
      end

      def deconstruct
        deconstruct_keys(nil).values
      end

      def deconstruct_keys(keys)
        hash = {
          resource_groups: resource_groups
        }

        keys ? hash.slice(*keys) : hash
      end

      def ==(other)
        deconstruct == other.deconstruct
      end
    end
  end
end
