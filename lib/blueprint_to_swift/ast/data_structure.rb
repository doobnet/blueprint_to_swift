# frozen_string_literal: true

module BlueprintToSwift
  module Ast
    class DataStructure
      attr_reader :content
      attr_reader :id

      # Initializes the receiver with the given arguments.
      #
      # @param content [Ast::Object, Ast::Array, Ast::DeferredType, Ast::Any]
      #   the data structures of the group
      #
      # @param id [String, nil] the id of the data structure
      def initialize(content, id = nil)
        @content = content
        @id = id
      end

      def deconstruct
        deconstruct_keys(nil).values
      end

      def deconstruct_keys(keys)
        hash = {
          content: content,
          id: id
        }

        keys ? hash.slice(*keys) : hash
      end

      def ==(other)
        deconstruct == other.deconstruct
      end
    end
  end
end
