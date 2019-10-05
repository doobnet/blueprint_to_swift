# frozen_string_literal: true

module BlueprintToSwift
  module Ast
    class DeferredType
      attr_reader :name

      # Initializes the receiver with the given arguments.
      #
      # @param name [String] the name of the deferred type
      def initialize(name)
        @name = name
      end

      def deconstruct
        deconstruct_keys(nil).values
      end

      def deconstruct_keys(keys)
        hash = { name: name }
        keys ? hash.slice(*keys) : hash
      end

      def ==(other)
        deconstruct == other.deconstruct
      end
    end
  end
end
