# frozen_string_literal: true

module BlueprintToSwift
  module Ast
    class Object
      attr_reader :members

      # Initializes the receiver with the given arguments.
      #
      # @param members [<Ast::Member>] the members of the object
      def initialize(members)
        @members = members
      end

      def deconstruct
        deconstruct_keys(nil).values
      end

      def deconstruct_keys(keys)
        hash = { members: members }
        keys ? hash.slice(*keys) : hash
      end

      def ==(other)
        deconstruct == other.deconstruct
      end
    end
  end
end
