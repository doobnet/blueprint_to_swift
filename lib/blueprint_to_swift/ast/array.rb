# frozen_string_literal: true

module BlueprintToSwift
  module Ast
    class Array
      attr_reader :elements

      # Initializes the receiver with the given arguments.
      #
      # @param elements [<Object>] the elements of the array
      def initialize(elements)
        @elements = elements
      end

      def deconstruct
        deconstruct_keys(nil).values
      end

      def deconstruct_keys(keys)
        hash = { elements: elements }
        keys ? hash.slice(*keys) : hash
      end

      def ==(other)
        deconstruct == other.deconstruct
      end
    end
  end
end
