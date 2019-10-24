# frozen_string_literal: true

module BlueprintToSwift
  module Ast
    class Api
      attr_accessor :categories

      def initialize(categories)
        @categories = categories
      end

      def deconstruct
        deconstruct_keys(nil).values
      end

      def deconstruct_keys(keys)
        hash = {
          categories: categories
        }

        keys ? hash.slice(*keys) : hash
      end

      def ==(other)
        deconstruct == other.deconstruct
      end
    end
  end
end
