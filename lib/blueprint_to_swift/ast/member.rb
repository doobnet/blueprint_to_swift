# frozen_string_literal: true

module BlueprintToSwift
  module Ast
    class Member
      attr_reader :name
      attr_reader :example
      attr_reader :description

      # Initializes the receiver with the given arguments.
      #
      # @param title [String] the name of the member
      # @param resource [String] an example value
      # @param optional [Boolean] specifies if the member is optional
      # @param description [String] the description of the member
      def initialize(name, example, optional, description = nil)
        @name = name
        @example = example
        @optional = optional
        @description = description
      end

      def optional?
        @optional
      end

      def deconstruct
        deconstruct_keys(nil).values
      end

      def deconstruct_keys(keys)
        hash = {
          name: name,
          example: example,
          optional: optional?,
          description: description
        }

        keys ? hash.slice(*keys) : hash
      end

      def ==(other)
        deconstruct == other.deconstruct
      end
    end
  end
end
