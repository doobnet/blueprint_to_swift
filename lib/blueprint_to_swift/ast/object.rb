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
    end
  end
end
