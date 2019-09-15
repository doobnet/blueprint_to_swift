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
  let(:type) { 'string' }
  let(:example) { 'user1' }
  let(:optional) { false }

  def value_to_type(value)
    case value
      when String then 'string'
      when Numeric then 'number'
      else
        raise "Unhandled type: #{value.class}"
    end
  end


  def drafter(value)
    case value
      when Array
        OpenStruct.new(element: 'array', content: value.map(&self.:drafter))
      when Hash
        OpenStruct.new(value.transform_values(&self.:drafter))
      when Numeric, String
        OpenStruct.new(element: value_to_type(value), content: value)
      when RubyArray
        value.array.map(&self.:drafter)
      when Symbol
        drafter(value.to_s)
      else
        raise "Unhandled type: #{value.class}"
    end
  end

  def new_data_structure(object = new_object)
    {
      element: 'dataStructure',
      content: object
    }
  end

  def new_object(members = [new_member])
    {
      element: 'object',
      content: RubyArray.new(members)
    }
  end

  def new_member(
    name: self.name,
    example: self.example,
    optional: self.optional,
    description: nil,
    default_value: nil
  )
    member = {
      element: 'member',
      attributes: { typeAttributes: optional ? [:optional] : [:required] },
      content: { key: name, value: example }
    }

    member[:meta] = { description: description } if description

    if default_value
      member[:content][:value] = {
        element: value_to_type(example),
        attributes: { default: default_value },
        content: example
      }
    end

    member
  end

  describe 'parse_data_structure' do
    let(:data_structure) { new_data_structure }

    let(:result) { BlueprintToSwift::Ast::Object.new([result_member]) }

    let(:result_member) do
      BlueprintToSwift::Ast::Member.new(
        name: name,
        type: type,
        example: example,
        optional: optional
      )
    end

    def parse_data_structure
      subject.send(:parse_data_structure, drafter(data_structure))
    end

    it 'parses an data structure' do
      expect(parse_data_structure).to eq(result)
    end
  end

  describe 'parse_object' do
    let(:object) { new_object }

    let(:result) { BlueprintToSwift::Ast::Object.new([result_member]) }

    let(:result_member) do
      BlueprintToSwift::Ast::Member.new(
        name: name,
        type: type,
        example: example,
        optional: optional
      )
    end

    def parse_object
      subject.send(:parse_object, drafter(object))
    end

    it 'parses an object' do
      expect(parse_object).to eq(result)
    end
  end

  describe 'parse_object_member' do
    let(:description) { nil }
    let(:default_value) { nil }

    let(:member) do
      new_member(description: description, default_value: default_value)
    end

    let(:result) do
      Ast::Member.new(
        name: name,
        type: type,
        example: example,
        optional: optional,
        description: description
      )
    end

    def parse_object_member
      subject.send(:parse_object_member, drafter(member))
    end

    it 'parses an object member' do
      expect(parse_object_member).to eq(result)
    end

    context 'when the member is required' do
      let(:optional) { false }
      let(:type_attributes) { [:required] }

      it 'returns a Member where "required?" is `false`' do
        expect(parse_object_member.optional?).to be false
      end
    end

    context 'when the member is optional' do
      let(:optional) { true }
      let(:type_attributes) { [:optional] }

      it 'returns a Member where "optional?" is `true`' do
        expect(parse_object_member.optional?).to be true
      end
    end

    context 'when the member has a description' do
      let(:description) { 'foobar' }

      it 'returns a Member where "description" has been set' do
        expect(parse_object_member.description).to eq(description)
      end
    end

    context 'when the type is a number' do
      let(:type) { 'number' }
      let(:example) { 60 }

      it 'returns a Member where "type" is `number`' do
        expect(parse_object_member.type).to eq(type)
      end
    end

    context 'when the member has a default value' do
      let(:default_value) { 'asd' }

      it 'returns a Member where "default_value" is `asd`' do
        expect(parse_object_member.default_value).to eq(default_value)
      end
    end
  end
end
