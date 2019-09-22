# frozen_string_literal: true

module BlueprintToSwift
  module Ast
    class Response
      attr_reader :status_code
      attr_reader :result

      # Initializes the receiver with the given arguments.
      #
      # @param status_code [Number] the status code of the response
      # @param result [<Ast::Member>] the result of the request
      def initialize(status_code, result)
        @status_code = status_code
        @result = result
      end

      def deconstruct
        deconstruct_keys(nil).values
      end

      def deconstruct_keys(keys)
        hash = {
          status_code: status_code,
          result: result
        }

        keys ? hash.slice(*keys) : hash
      end

      def ==(other)
        deconstruct == other.deconstruct
      end
    end
  end
end
