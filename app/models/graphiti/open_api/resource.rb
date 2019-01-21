require "graphiti/open_api"
require "active_model"
require_relative "struct"
require_relative "attribute"
require_relative "relationship"

module Graphiti::OpenAPI
  class ResourceData < Struct
    attribute :name, Types::String
    attribute :type, Types::String
    attribute :description, Types::String.optional
    attribute :attributes, Types::Hash.map(Types::Symbol, AttributeData)
    attribute :extra_attributes, Types::Hash.map(Types::Symbol, AttributeData)
    attribute :sorts, Types::Hash.map(Types::Symbol, Types::Hash)
    attribute :filters, Types::Hash.map(Types::Symbol, Types::Hash)
    attribute :relationships, Types::Hash.map(Types::Symbol, RelationshipData)

    def relationships
      Relationships.load(self)
    end

    def relationships?
      relationships.any?
    end

    memoize :relationships
  end

  class Resource < ResourceData
    include Parameters

    attribute :schema, Types::Any

    def model_name
      ActiveModel::Name.new(self.class, nil, name.gsub(/Resource/, ""))
    end

    def_instance_delegators :model_name, :human, :singular, :plural

    def plural_human(**options)
      human(**options).pluralize
    end

    def attributes
      Attributes.load(self)
    end

    def extra_attributes
      Attributes.load(self, __attributes__[:extra_attributes])
    end

    def all_attributes
      attributes.merge(extra_attributes)
    end

    def resource_attributes
      all_attributes.except(:id).values
    end

    def readable_attributes
      all_attributes.values.select(&:readable)
    end

    def sortable_attributes
      sortable_attribute_names = sorts.keys
      all_attributes.values.select { |attribute| sortable_attribute_names.include?(attribute.name) }
    end

    def writable_attributes
      all_attributes.values.select(&:writable)
    end

    def query_parameters
      [].tap do |result|
        result << query_include_parameter
        result << query_fields_parameter
      end
    end

    def query_fields_parameter
      schema = {
        description: "#{human} readable attributes list",
        type: :array,
        items: {'$ref': "#/components/schemas/#{type}_readable_attribute"},
        uniqueItems: true,
      }

      query_parameter("fields[#{type}]",
                      desc: "[Include only specified fields of #{human} in response](https://jsonapi.org/format/#fetching-sparse-fieldsets)",
                      schema: schema,
                      explode: false)
    end

    def query_include_parameter
      return unless relationships?

      query_parameter(:include, desc: "[Include related resources](https://jsonapi.org/format/#fetching-includes)", schema: {'$ref': "#/components/schemas/#{type}_related"}, explode: false)
    end

    def query_sort_parameter(relationships: false)
      return unless sorts.any?
      orderings = sorts.keys.map { |id| %W[#{id} -#{id}] }.flatten
      if relationships
        relationships.each do |name, relationship|
          relationship.resources.each do |resource|
            orderings += resource.sorts.keys.map { |id| %W[#{name}.#{id} -#{name}.#{id}] }.flatten
          end
        end
      end
      query_parameter(:sort,
                      desc: "[Sort #{model_name.plural} according to one or more criteria](https://jsonapi.org/format/#fetching-sorting)\n\n" \
                            "You should not include both ascending `id` and descending `-id` fields the same time\n\n",
                      schema: {"$ref" => "#/components/schemas/#{type}_sortable_attributes_list"}, explode: false)
    end

    def to_parameters
      {
        "#{type}_id": path_parameter(:id, schema: {type: :string}, desc: "ID of the resource"),
        "#{type}_include": query_include_parameter,
        "#{type}_fields": query_fields_parameter,
        "#{type}_sort": query_sort_parameter,
      }.keep_if { |name, value| value }
    end

    def to_schema
      attributes_schema
        .merge(relationships_schema)
        .merge(resource_schema)
        .merge(response_schema)
        .merge(request_schema)
        .merge(attribute_schemas)
    end

    def attributes_schema
      {
        type => {
          type: :object,
          description: "#{human} attributes",
          properties: resource_attributes.map(&:to_property).inject(&:merge),
          additionalProperties: false,
        },
      }
    end

    def relationships_schema
      schema_name = "#{type}_relationships"
      return {schema_name => {'$ref': "#/components/schemas/jsonapi_relationships"}} unless relationships?
      {
        schema_name => {
          type: :object,
          properties: relationships.values.map(&:to_schema).inject(&:merge),
          additionalProperties: false,
        },
      }
    end

    def resource_schema
      {
        "#{type}_resource" => {
          type: :object,
          properties: {
            id: {type: :string, example: rand(100).to_s},
            type: {type: :string, enum: [type]},
            attributes: {'$ref': "#/components/schemas/#{type}"},
            relationships: {'$ref': "#/components/schemas/#{type}_relationships"},
            links: {'$ref': "#/components/schemas/jsonapi_links"},
          },
          additionalProperties: false,
        },
      }
    end

    def response_schema
      {
        "#{type}_single" => {
          type: :object,
          allOf: [
            {'$ref': "#/components/schemas/jsonapi_success"},
            {
              type: :object,
              properties: {
                data: {'$ref': "#/components/schemas/#{type}_resource"},
              },
            },
          ],
        },
        "#{type}_collection" => {
          type: :object,
          allOf: [
            {'$ref': "#/components/schemas/jsonapi_success"},
            {
              type: :object,
              properties: {
                data: {
                  type: :array,
                  items: {"$ref" => "#/components/schemas/#{type}_resource"},
                },
              },
            },
          ],
        },
      }
    end

    def request_schema
      {
        "#{type}_request" => {
          type: :object,
          properties: {
            data: {'$ref': "#/components/schemas/#{type}_resource"},
          },
        # xml: {name: :data},
        },
      }
    end

    def attribute_schemas
      types = {
        "#{type}_readable_attribute" => {
          description: "#{human} readable attributes",
          type: :string,
          enum: readable_attributes.map(&:name),
        },
        "#{type}_sortable_attributes_list" => {
          description: "#{human} sortable attributes",
          type: :array,
          items: {
            type: :string,
            enum: sortable_attribute_names.map { |name| %W[#{name} -#{name}] }.flatten,
          },
          uniqueItems: true,
        },
        "#{type}_related" => {
          description: "#{human} relationships available for inclusion",
          type: :array,
          items: {type: :string},
          uniqueItems: true,
        },

      }
      if relationship_names.any?
        types["#{type}_related"][:items][:enum] = relationship_names
      else
        types["#{type}_related"][:nullable] = true
      end
      types
    end

    def to_responses
      {
        "#{type}_200" => {
          description: "OK: #{human} resource",
          content: {
            "application/vnd.api+json" => {schema: {"$ref": "#/components/schemas/#{type}_single"}},
          # "application/xml" => {schema: {"$ref": "#/components/schemas/#{type}_single"}},
          },
          links: link_refs,
        },
        "#{type}_200_collection" => {
          description: "OK: #{plural_human} collection",
          content: {
            "application/vnd.api+json" => {schema: {"$ref": "#/components/schemas/#{type}_collection"}},
          # "application/xml" => {schema: {"$ref": "#/components/schemas/#{type}_collection"}},
          },
        },
        "#{type}_201" => {
          description: "Created",
          content: {
            "application/vnd.api+json" => {schema: {"$ref": "#/components/schemas/#{type}_single"}},
          # "application/xml" => {schema: {"$ref": "#/components/schemas/#{type}_single"}},
          },
          links: link_refs,
        },
      }
    end

    def to_links
      %i[get update delete].inject({}) do |result, method|
        operation_id = "#{method}_#{model_name.singular}".camelize(:lower)
        result.merge(
          "#{operation_id}Id": {
            operationId: operation_id,
            parameters: {id: "$response.body#/data/id"},
          },
        )
      end
    end

    memoize :model_name, :attributes, :query_parameters, :to_schema, :to_responses, :to_links

    private

    def link_refs
      to_links.keys.inject({}) { |result, link| result.merge(link => {'$ref': "#/components/links/#{link}"}) }
    end

    def relationship_names
      relationships.keys
    end

    def sortable_attribute_names
      sortable_attributes.map(&:name)
    end
  end

  class Resources < Hash
    # @param [<ResourceData>]
    def self.load(schema, data = schema.__attributes__[:resources])
      data.each_with_object(new) do |resource, result|
        result[resource.name] = Resource.new(resource.to_hash.merge(schema: schema))
      end
    end

    def by_model(model)
      fetch("#{model}Resource")
    end

    def by_type(type)
      values.detect { |resource| resource.type = type }
    end
  end
end
