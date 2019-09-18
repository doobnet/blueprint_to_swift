# frozen_string_literal: true

module BlueprintToSwift
  module Ast
    class Response
      attr_reader :status_code
      attr_reader :members

      # Initializes the receiver with the given arguments.
      #
      # @param status_code [Number] the status code of the response
      # @param members [<Ast::Member>] the members of the response object
      def initialize(status_code, members)
        @status_code = status_code
        @members = members
      end

      def deconstruct
        deconstruct_keys(nil).values
      end

      def deconstruct_keys(keys)
        hash = {
          status_code: status_code,
          members: members
        }

        keys ? hash.slice(*keys) : hash
      end

      def ==(other)
        deconstruct == other.deconstruct
      end
    end
  end
end
