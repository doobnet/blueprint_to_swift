# frozen_string_literal: true

class RubyArray
  attr_reader :array

  def initialize(array)
    @array = array
  end

  def deconstruct
    array
  end
end

describe BlueprintToSwift::DrafterJsonParser do
  Ast = BlueprintToSwift::Ast

  let(:name) { 'username' }
  let(:example) { 'user1' }
  let(:required) { false }
  let(:member) { new_member(name, example, required) }

  def drafter(value)
    case value
      when Array
        OpenStruct.new(element: 'array', content: value.map(&self.:drafter))
      when Hash
        OpenStruct.new(value.transform_values(&self.:drafter))
      when RubyArray
        value.array.map(&self.:drafter)
      when String
        OpenStruct.new(element: 'string', content: value)
      when Symbol
        drafter(value.to_s)
    end
  end

  def new_object(*members)
    {
      element: 'object',
      content: RubyArray.new(members)
    }
  end

  def new_member(name, example, required = false)
    {
      element: 'member',
      attributes: { typeAttributes: required ? [:required] : [] },
      content: { key: name, value: example }
    }
  end

  describe 'parse_object' do
    let(:member) { new_member(name, example, required) }
    let(:object) { new_object(member) }

    let(:result) { BlueprintToSwift::Ast::Object.new([result_member]) }

    let(:result_member) do
      BlueprintToSwift::Ast::Member.new(name, example, required)
    end

    def parse_object
      subject.send(:parse_object, drafter(object))
    end

    it 'parses an object' do
      expect(parse_object).to eq(result)
    end
  end

  describe 'parse_object_member' do
    let(:result) { Ast::Member.new(name, example, required) }

    def parse_object_member
      subject.send(:parse_object_member, drafter(member))
    end

    it 'parses an object member' do
      expect(parse_object_member).to eq(result)
    end

    context 'when the member is required' do
      let(:required) { true }
      let(:type_attributes) { [:required] }

      it 'returns a Member where "required?" is `true`' do
        expect(parse_object_member.required?).to be true
      end
    end

    context 'when the member is optional' do
      let(:required) { false }
      let(:type_attributes) { [] }

      it 'returns a Member where "required?" is `false`' do
        expect(parse_object_member.required?).to be false
      end
    end
  end
end
