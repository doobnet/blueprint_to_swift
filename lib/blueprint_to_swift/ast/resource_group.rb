# frozen_string_literal: true

module BlueprintToSwift
  module Ast
    class ResourceGroup
      attr_reader :title
      attr_reader :description
      attr_reader :resources

      # Initializes the receiver with the given arguments.
      #
      # @param title [String] the title of the resource group
      # @param description [String, nil] the description of the resource group
      # @param resource [<Ast::Resource>] the resources the group contains
      def initialize(title, description, resources)
        @title = title
        @description = description
        @resources = resources
      end

      def deconstruct
        deconstruct_keys(nil).values
      end

      def deconstruct_keys(keys)
        hash = {
          title: title,
          description: description,
          resources: resources
        }

        keys ? hash.slice(*keys) : hash
      end

      def ==(other)
        deconstruct == other.deconstruct
      end
    end
  end
end
