# frozen_string_literal: true

describe BlueprintToSwift::DrafterJsonParser do
  def drafter(value)
    case value
      when Array
        OpenStruct.new(element: 'array', content: value.map(&self.:drafter))
      when Hash
        OpenStruct.new(value.transform_values(&self.:drafter))
      when String
        OpenStruct.new(element: 'string', content: value)
      when Symbol
        drafter(value.to_s)
    end
  end

  describe 'parse_object_member' do
    let(:name) { 'username' }
    let(:example) { 'user1' }

    let(:required) { false }
    let(:type_attributes) { [] }
    let(:attributes) { { typeAttributes: type_attributes } }
    let(:content) { { key: name, value: example } }

    let(:member) do
      {
        element: 'member',
        attributes: attributes,
        content: content
      }
    end

    let(:result) { BlueprintToSwift::Ast::Member.new(name, example, required) }

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
