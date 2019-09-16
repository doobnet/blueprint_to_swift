# frozen_string_literal: true

module BlueprintToSwift
  module Ast
    class Request
      attr_reader :method
      attr_reader :parameters

      # Initializes the receiver with the given arguments.
      #
      # @param title [String] the name of the member
      def initialize(method, parameters)
        @method = method
        @parameters = parameters
      end

      def deconstruct
        deconstruct_keys(nil).values
      end

      def deconstruct_keys(keys)
        hash = {
          method: method,
          parameters: parameters
        }

        keys ? hash.slice(*keys) : hash
      end

      def ==(other)
        deconstruct == other.deconstruct
      end
    end
  end
end
