# frozen_string_literal: true

describe BlueprintToSwift::DrafterJsonParser do
  class RubyArray
    attr_reader :array

    def initialize(array)
      @array = array
    end

    def deconstruct
      [array]
    end
  end

  class RubyString
    attr_reader :string

    def initialize(string)
      @string = string
    end

    def deconstruct
      [string]
    end
  end

  def ruby_array(array)
    RubyArray.new(array)
  end

  def ruby_string(string)
    RubyString.new(string)
  end

  Ast = BlueprintToSwift::Ast

  let(:status_code) { '200' }
  let(:name) { 'username' }
  let(:type) { 'string' }
  let(:example) { 'user1' }
  let(:optional) { false }
  let(:method) { 'POST' }

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
      in Array
        OpenStruct.new(element: 'array', content: value.map(&self.:drafter))
      in Hash
        OpenStruct.new(value.transform_values(&self.:drafter))
      in Numeric | String
        OpenStruct.new(element: value_to_type(value), content: value)
      in RubyArray(array)
        array.map(&self.:drafter)
      in RubyString(string)
        string
      in Symbol
        drafter(value.to_s)
      else
        raise "Unhandled type: #{value.class}"
    end
  end

  def new_http_transaction(request: new_request, response: new_response)
    {
      element: ruby_string('httpTransaction'),
      content: ruby_array([request, response])
    }
  end

  def new_headers
    {
      element: ruby_string('httpHeaders'),
      content: ruby_array([
        element: ruby_string('member'),
        content: {
          key: 'Content-Type',
          value: 'application/json'
        }
      ])
    }
  end

  def new_response(
    status_code: self.status_code,
    data_structure: new_data_structure
  )
    {
      element: ruby_string('httpResponse'),
      attributes: { statusCode: status_code },
      headers: new_headers,
      content: ruby_array([data_structure])
    }
  end

  def new_request(
    method: self.method,
    data_structure: new_data_structure
  )
    {
      element: ruby_string('httpRequest'),
      attributes: { method: method },
      headers: new_headers,
      content: ruby_array([data_structure])
    }
  end

  def new_data_structure(object = new_object)
    {
      element: ruby_string('dataStructure'),
      content: object
    }
  end

  def new_object(members = [new_member])
    {
      element: ruby_string('object'),
      content: ruby_array(members)
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

  describe 'parse_http_transaction' do
    let(:documentation) { 'foobar asd' }
    let(:http_transaction) { new_http_transaction }

    let(:result) do
      Ast::HttpTransaction.new(request, [response], documentation)
    end

    let(:request) { Ast::Request.new(method, [member]) }
    let(:response) { Ast::Response.new(status_code.to_i, [member]) }

    let(:member) do
      BlueprintToSwift::Ast::Member.new(
        name: name,
        type: type,
        example: example,
        optional: optional
      )
    end

    def parse_http_transaction
      subject.send(:parse_http_transaction, drafter(http_transaction),
        documentation)
    end

    it 'parses a http_transaction' do
      expect(parse_http_transaction).to eq(result)
    end
  end

  describe 'parse_response' do
    let(:response) { new_response }
    let(:result) { Ast::Response.new(status_code.to_i, [result_member]) }

    let(:result_member) do
      BlueprintToSwift::Ast::Member.new(
        name: name,
        type: type,
        example: example,
        optional: optional
      )
    end

    def parse_response
      subject.send(:parse_response, drafter(response))
    end

    it 'parses a response' do
      expect(parse_response).to eq(result)
    end
  end

  describe 'parse_request' do
    let(:request) { new_request }
    let(:result) { Ast::Request.new(method, [result_member]) }

    let(:result_member) do
      BlueprintToSwift::Ast::Member.new(
        name: name,
        type: type,
        example: example,
        optional: optional
      )
    end

    def parse_request
      subject.send(:parse_request, drafter(request))
    end

    it 'parses a request' do
      expect(parse_request).to eq(result)
    end
  end

  describe 'parse_data_structure' do
    let(:data_structure) { new_data_structure }

    let(:result) { [result_member] }

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

    let(:result) { [result_member] }

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
