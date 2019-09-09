# frozen_string_literal: true

module BlueprintToSwift
  module Ast
    class ResourceGroup
      attr_reader :title
      attr_reader :resources

      # Initializes the receiver with the given arguments.
      #
      # @param title [String] the title of the resource group
      # @param resource [<Ast::Resource>] the resources the group contains
      def initialize(title, resources)
        @title = title
        @resources = resources
      end
    end
  end
end
