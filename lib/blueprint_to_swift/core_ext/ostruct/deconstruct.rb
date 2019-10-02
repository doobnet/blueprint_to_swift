# frozen_string_literal: true

module Deconstruct
  def deconstruct_keys(keys)
    to_h.deconstruct_keys(keys)
  end

  def deconstruct
    to_h.values.deconstruct
  end
end

class OpenStruct
  include Deconstruct
end
