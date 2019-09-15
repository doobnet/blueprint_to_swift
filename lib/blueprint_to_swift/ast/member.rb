# frozen_string_literal: true

module BlueprintToSwift
  module Ast
    class Member
      attr_reader :name
      attr_reader :example

      # Initializes the receiver with the given arguments.
      #
      # @param title [String] the name of the member
      # @param resource [String] an example value
      # @param optional [Boolean] specifies if the member is optional
      def initialize(name, example, optional)
        @name = name
        @example = example
        @optional = optional
      end

      def optional?
        @optional
      end

      def deconstruct
        deconstruct_keys(nil).values
      end

      def deconstruct_keys(keys)
        hash = { name: name, example: example, optional: optional? }
        keys ? hash.slice(*keys) : hash
      end

      def ==(other)
        deconstruct == other.deconstruct
      end
    end
  end
end
