# frozen_string_literal: true

module BlueprintToSwift
  module Ast
    class Api
      attr_accessor :resource_groups

      def initialize(resource_groups)
        @resource_groups = resource_groups
      end
    end
  end
end
