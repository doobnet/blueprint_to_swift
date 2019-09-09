# frozen_string_literal: true

module BlueprintToSwift
  module Ast
    class Resource
      attr_reader :title
      attr_reader :path
      attr_reader :http_transactions

      # Initializes the receiver with the given arguments.
      #
      # @param title [String] the title of the resource
      # @param path [String] the path of the resource
      # @param http_transactions [<Ast::HttpTransaction>] the HTTP transactions
      #   contained in this resource
      def initialize(title, path, http_transactions)
        @title = title
        @path = path
        @http_transactions = http_transactions
      end
    end
  end
end
