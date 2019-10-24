# frozen_string_literal: true

module BlueprintToSwift
  module Ast
    class DataStructureGroup
      attr_reader :data_structures

      # Initializes the receiver with the given arguments.
      #
      # @param data_structures [<Ast::Object, Ast::Array, Ast::DeferredType>]
      #   the data structures of the group
      def initialize(data_structures)
        @data_structures = data_structures
      end

      def deconstruct
        deconstruct_keys(nil).values
      end

      def deconstruct_keys(keys)
        hash = {
          data_structures: data_structures
        }

        keys ? hash.slice(*keys) : hash
      end

      def ==(other)
        deconstruct == other.deconstruct
      end
    end
  end
end
