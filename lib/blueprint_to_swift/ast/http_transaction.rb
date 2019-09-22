# frozen_string_literal: true

module BlueprintToSwift
  module Ast
    class HttpTransaction
      attr_reader :request
      attr_reader :responses
      attr_reader :documentation

      # Initializes the receiver with the given arguments.
      #
      # @param request [Ast::Request] the request
      # @param responses [<Ast::Responses>] the set of responses
      # @param documentation [String] the documentation
      def initialize(request, responses, documentation)
        @request = request
        @responses = responses
        @documentation = documentation
      end

      def deconstruct
        deconstruct_keys(nil).values
      end

      def deconstruct_keys(keys)
        hash = {
          request: request,
          responses: responses,
          documentation: documentation
        }

        keys ? hash.slice(*keys) : hash
      end

      def ==(other)
        deconstruct == other.deconstruct
      end
    end
  end
end
