# frozen_string_literal: true

module BlueprintToSwift
  module Ast
    class Member
      attr_reader :name
      attr_reader :type
      attr_reader :example
      attr_reader :description
      attr_reader :default_value

      # Initializes the receiver with the given arguments.
      #
      # @param title [String] the name of the member
      # @param type [String] the type of the member
      # @param resource [String] an example value
      # @param optional [Boolean] specifies if the member is optional
      # @param description [String] the description of the member
      # @param default_value [Object] the default value, or `nil` if none
      def initialize(name:, type:, example:, optional:, description: nil,
        default_value: nil)
        @name = name
        @type = type
        @example = example
        @optional = optional
        @description = description
        @default_value = default_value
      end

      def optional?
        @optional
      end

      def deconstruct
        deconstruct_keys(nil).values
      end

      def deconstruct_keys(keys)
        hash = {
          name: name,
          type: type,
          example: example,
          optional: optional?,
          description: description,
          default_value: default_value
        }

        keys ? hash.slice(*keys) : hash
      end

      def ==(other)
        deconstruct == other.deconstruct
      end
    end
  end
end
