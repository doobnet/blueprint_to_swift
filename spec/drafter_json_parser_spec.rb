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

  let(:resource_group_title) { 'Sessions' }
  let(:resource_group_description) { 'Session API provides methods for' }

  let(:resource_title) { 'Authentication' }
  let(:resource_path) { '/sessions/authorize' }
  let(:transition_title) { 'Create session' }
  let(:transition_documentation) { 'Create a new API session by providing' }

  let(:status_code) { '200' }
  let(:name) { 'username' }
  let(:type) { 'string' }
  let(:example) { 'user1' }
  let(:optional) { false }
  let(:method) { 'POST' }

  let(:member_attributes) do
    { typeAttributes: optional ? [:optional] : [:required] }
  end

  let(:data_structure_group) { Ast::DataStructureGroup.new([data_structure]) }
  let(:data_structure) { object }

  let(:resource_group) do
    Ast::ResourceGroup.new(
      resource_group_title,
      resource_group_description,
      [resource]
    )
  end

  let(:resource) do
    Ast::Resource.new(resource_title, resource_path, [http_transaction])
  end

  let(:http_transaction) do
    Ast::HttpTransaction.new(request, [response], transition_documentation)
  end

  let(:request) { Ast::Request.new(method, object) }
  let(:response) { Ast::Response.new(status_code.to_i, object) }
  let(:object) { Ast::Object.new([member]) }

  let(:member) do
    BlueprintToSwift::Ast::Member.new(
      name: name,
      type: type,
      example: example,
      optional: optional
    )
  end

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
      in nil
        nil
      else
        raise "Unhandled type: #{value.class}"
    end
  end

  def new_api(resource_groups = [new_resource_group])
    {
      element: ruby_string('category'),
      meta: {
        classes: [:api],
        title: ''
      },
      content: ruby_array(resource_groups)
    }
  end

  def new_resource_group(
    title: resource_group_title,
    description: resource_group_description,
    resources: [new_resource]
  )
    {
      element: ruby_string('category'),
      meta: {
        classes: [:resourceGroup],
        title: resource_group_title
      },
      content: ruby_array([
        {
          element: ruby_string('copy'),
          content: ruby_string(description)
        },
        *resources
      ])
    }
  end

  def new_data_structure_group(
    data_structures: [new_data_structure]
  )
    {
      element: ruby_string('category'),
      meta: {
        classes: [:dataStructures],
      },
      content: ruby_array(data_structures)
    }
  end

  def new_resource(
    title: resource_title,
    path: resource_path,
    transition_title: self.transition_title,
    transition_documentation: self.transition_documentation,
    http_transactions: [new_http_transaction]
  )
    {
      element: ruby_string('resource'),
      meta: { title: title },
      attributes: { href: path },
      content: ruby_array([
        {
          element: ruby_string('transition'),
          meta: { title: transition_title },
          content: ruby_array([
            {
              element: ruby_string('copy'),
              content: ruby_string(transition_documentation)
            },
            *http_transactions
          ])
        }
      ])
    }
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
    default_value: nil,
    attributes: self.member_attributes
  )
    member = {
      element: 'member',
      content: { key: name, value: example }
    }

    member[:meta] = { description: description } if description
    member[:attributes] = attributes if attributes

    if default_value
      member[:content][:value] = {
        element: value_to_type(example),
        attributes: { default: default_value },
        content: example
      }
    end

    member
  end

  describe 'parse' do
    let(:result) { [Ast::Api.new([resource_group])] }

    def parse
      subject.send(:parse, data('basic.json'))
    end

    it 'parses APIs' do
      expect(parse).to eq(result)
    end
  end

  describe 'parse_api' do
    let(:api) { new_api }

    let(:result) { Ast::Api.new([resource_group]) }

    def parse_api
      subject.send(:parse_api, drafter(api))
    end

    it 'parses an API' do
      expect(parse_api).to eq(result)
    end
  end

  describe 'parse_category' do
    def parse_category
      subject.send(:parse_category, drafter(category))
    end

    context 'when the category is a resource group' do
      let(:category) { new_resource_group }
      let(:result) { resource_group }

      it 'returns and instance of `Ast::ResourceGroup`' do
        expect(parse_category).to eq(result)
      end
    end

    context 'when the category is a data structure group' do
      let(:category) { new_data_structure_group }
      let(:result) { data_structure_group }

      it 'returns and instance of `Ast::DataStructureGroup`' do
        expect(parse_category).to eq(result)
      end
    end
  end

  describe 'parse_resource_group' do
    let(:resource_group) { new_resource_group }

    let(:result) do
      Ast::ResourceGroup.new(
        resource_group_title,
        resource_group_description,
        [resource]
      )
    end

    def parse_resource_group
      subject.send(:parse_resource_group, drafter(resource_group))
    end

    it 'parses a resource group' do
      expect(parse_resource_group).to eq(result)
    end
  end

  describe 'parse_resource' do
    let(:resource) { new_resource }

    let(:result) do
      Ast::Resource.new(resource_title, resource_path, [http_transaction])
    end

    def parse_resource
      subject.send(:parse_resource, drafter(resource))
    end

    it 'parses a resource' do
      expect(parse_resource).to eq(result)
    end
  end

  describe 'parse_http_transaction' do
    let(:documentation) { 'foobar asd' }
    let(:http_transaction) { new_http_transaction }

    let(:result) do
      Ast::HttpTransaction.new(request, [response], documentation)
    end

    def parse_http_transaction
      subject.send(:parse_http_transaction, drafter(http_transaction),
        documentation)
    end

    it 'parses an HTTP transaction' do
      expect(parse_http_transaction).to eq(result)
    end
  end

  describe 'parse_response' do
    let(:response) { new_response }
    let(:result) { Ast::Response.new(status_code.to_i, object) }

    def parse_response
      subject.send(:parse_response, drafter(response))
    end

    it 'parses a response' do
      expect(parse_response).to eq(result)
    end
  end

  describe 'parse_request' do
    let(:request) { new_request }
    let(:result) { Ast::Request.new(method, object) }

    def parse_request
      subject.send(:parse_request, drafter(request))
    end

    it 'parses a request' do
      expect(parse_request).to eq(result)
    end
  end

  describe 'parse_data_structure' do
    let(:data_structure) { new_data_structure }
    let(:result) { Ast::Object.new([member]) }

    def parse_data_structure
      subject.send(:parse_data_structure, drafter(data_structure))
    end

    it 'parses an data structure' do
      expect(parse_data_structure).to eq(result)
    end

    context 'when the given data structure is `nil`' do
      let(:data_structure) { nil }

      it 'returns an empty array' do
        expect(parse_data_structure).to be_empty
      end
    end
  end

  describe 'parse_data_structure_content' do
    def parse_data_structure_content
      subject.send(:parse_data_structure_content, drafter(content))
    end

    context 'when the given content is an object' do
      let(:content) { new_object }
      let(:result) { Ast::Object.new([member]) }

      it 'returns an instance of Ast::Object' do
        expect(parse_data_structure_content).to eq(result)
      end
    end

    context 'when the given content is an array' do
      let(:content) { [new_object] }
      let(:result) { Ast::Array.new([Ast::Object.new([member])]) }

      it 'returns an instance of Ast::Array' do
        expect(parse_data_structure_content).to eq(result)
      end
    end

    context 'when the given content is an "deferred" type' do
      let(:deferred_type) { 'foo' }
      let(:content) { { element: ruby_string(deferred_type) } }
      let(:result) { Ast::DeferredType.new(deferred_type) }

      it 'returns an instance of Ast::DeferredType' do
        expect(parse_data_structure_content).to eq(result)
      end
    end
  end

  describe 'parse_object' do
    let(:object) { new_object }
    let(:result) { Ast::Object.new([member]) }

    def parse_object
      subject.send(:parse_object, drafter(object).content)
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

    context 'when the member has no attributes' do
      let(:member_attributes) { nil }

      it 'successfully parses an object member' do
        expect { parse_object_member }.to_not raise_error
      end
    end
  end
end
