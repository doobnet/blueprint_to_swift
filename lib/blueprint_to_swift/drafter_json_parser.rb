# frozen_string_literal: true

module BlueprintToSwift
  # Parses the JSON output of the [Drafter](https://github.com/apiaryio/drafter)
  # tool.
  class DrafterJsonParser
    def parse_from_file(path)
      parse(File.read(path))
    end

    # Parses the output of the Drafter tool.
    #
    # @param content [String] the JSON output of the Drafter tool
    #
    # @return [<Ast::Api>] a structure representing
    def parse(content)
      JSON
        .parse(content, object_class: OpenStruct)
        .content
        .filter { category?(_1) && type(_1) == 'api' }
        .map { parse_api(_1) }
    end

    private

    def parse_api(api)
      categories = api
        .content
        .filter { category?(_1) }
        .map { parse_category(_1) }

      Ast::Api.new(categories)
    end

    def parse_category(category)
      case type(category)
        in 'resourceGroup' then parse_resource_group(category)
        in 'dataStructures' then parse_data_structures(category)
        in type then raise "Unrecognized category: #{type}"
      end
    end

    def parse_resource_group(resource_group)
      resources = resource_group
        .content
        .filter { _1.element == 'resource' }
        .map { parse_resource(_1) }

      description = resource_group
        .content
        .find { _1.element == 'copy' }
        &.content

      Ast::ResourceGroup.new(title(resource_group), description, resources)
    end

    def parse_data_structures(data_structures)
      parsed_data_structure = data_structures
        .content
        .filter { _1.element == 'dataStructure' }
        .map { parse_data_structure(_1) }

      Ast::DataStructureGroup.new(parsed_data_structure)
    end

    def parse_resource(resource)
      title = title(resource)
      path = resource.attributes.href.content

      http_transactions = resource
        .content
        .filter { _1.element == 'transition' }
        .flat_map { parse_transition(_1) }

      Ast::Resource.new(title, path, http_transactions)
    end

    # @return [<Ast::HttpTransaction>]
    def parse_transition(transition)
      documentation = transition
        .content
        .find { _1.element == 'copy' }
        &.content

      transition
        .content
        .filter { _1.element == 'httpTransaction' }
        .map { parse_http_transaction(_1, documentation) }
    end

    def parse_http_transaction(http_transaction, documentation)
      content = http_transaction.content
      request = parse_request(content.find { _1.element == 'httpRequest' })

      responses = content
        .filter { _1.element == 'httpResponse' }
        .map { parse_response(_1) }

      Ast::HttpTransaction.new(request, responses, documentation)
    end

    def parse_request(request)
      raise ArgumentError, 'the given request is nil' unless request

      method = request.attributes['method'].content
      data_structure = request.content.find { _1.element == 'dataStructure' }
      parameters = parse_data_structure(data_structure)

      Ast::Request.new(method, parameters)
    end

    def parse_response(response)
      status_code = response.attributes.statusCode.content.to_i
      data_structure = response.content.find { _1.element == 'dataStructure' }
      parameters = parse_data_structure(data_structure)

      Ast::Response.new(status_code, parameters)
    end

    def parse_data_structure(data_structure)
      return [] unless data_structure
      parse_data_structure_content(data_structure.content)
    end

    def parse_data_structure_content(content)
      case content
        in element: 'array', content: c then parse_array(c)
        in element: 'object' then parse_object(content)
        in element: element then parse_deferred_type(element)
      end
    end

    def parse_deferred_type(element)
      Ast::DataStructure.new(Ast::DeferredType.new(element))
    end

    def parse_array(array)
      content = Ast::Array.new(array.map { parse_data_structure_content(_1) })
      Ast::DataStructure.new(content)
    end

    def parse_object(object)
      members = object.content&.map { parse_object_member(_1) } || []
      content = Ast::Object.new(members)
      id = object.meta&.id&.content
      Ast::DataStructure.new(content, id)
    end

    def parse_object_member(member)
      is_optional = member
        .attributes
        &.typeAttributes
        &.content
        &.any? { _1.content == 'optional' } || false

      name = member.content.key.content
      type = member.content.value.element
      example = member.content.value.content
      description = member.meta&.description&.content
      default_value = member.content.value.attributes&.default&.content

      Ast::Member.new(
        name: name,
        type: type,
        example: example,
        optional: is_optional,
        description: description,
        default_value: default_value
      )
    end

    # @return [String] the title of the given element
    def title(element)
      element.meta.title.content
    end

    # @return [String] the type of the given element
    def type(element)
      element.meta&.classes&.content&.first&.content
    end

    # @return [Boolean] `true` if the given element is a category
    def category?(element)
      element.element == 'category'
    end
  end
end
