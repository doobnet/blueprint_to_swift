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
    # @return [Object] a structure representing
    def parse(content)
      JSON
        .parse(content, object_class: OpenStruct)
        .content
        .filter { category?(@1) && type(@1) == 'api' }
        .map(&self.:parse_api)
    end

    private

    def parse_api(api)
      resource_groups = api
        .content
        .filter { category?(@1) && type(@1) == 'resourceGroup' }
        .map(&self.:parse_resource_group)

      Ast::Api.new(resource_groups)
    end

    def parse_resource_group(resource_group)
      resources = resource_group
        .content
        .filter { @1.element == 'resource' }
        .map(&self.:parse_resource)

      Ast::ResourceGroup.new(title(resource_group), resources)
    end

    def parse_resource(resource)
      title = title(resource)
      path = resource.attributes.href.content

      http_transactions = resource
        .content
        .filter { @1.element == 'transition' }
        .flat_map(&self.:parse_transition)

      Ast::Resource.new(title, path, http_transactions)
    end

    # @return [<Ast::HttpTransaction>]
    def parse_transition(transition)
      documentation = transition
        .content
        .find { @1.element == 'copy' }
        &.content

      transition
        .content
        .filter { @1.element == 'httpTransaction' }
        .map { parse_http_transaction(@1, documentation) }
    end

    def parse_http_transaction(http_transaction, documentation)
      content = http_transaction.content
      request = parse_request(content.find { @1.element == 'httpRequest' })

      responses = content
        .filter { @1.element == 'httpResponse' }
        .map(&self.:parse_response)

      Ast::HttpTransaction.new(request, responses, documentation)
    end

    def parse_request(request)
      raise ArgumentError, 'the given request is nil' unless request

      method = request.attributes['method'].content
      data_structure = request.content.find { @1.element == 'dataStructure' }
      parameters = parse_data_structure(data_structure)

      Ast::Request.new(method, parameters)
    end

    def parse_response(response)
      status_code = response.attributes.statusCode.content.to_i
      data_structure = response.content.find { @1.element == 'dataStructure' }
      parameters = parse_data_structure(data_structure)

      Ast::Response.new(status_code, parameters)
    end

    def parse_data_structure(data_structure)
      parse_object(data_structure.content)
    end

    def parse_object(object)
      object.content.map(&self.:parse_object_member)
    end

    def parse_object_member(member)
      is_optional = member
        .attributes
        .typeAttributes
        .content
        .any? { @1.content == 'optional' }

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
