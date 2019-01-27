require "graphiti/open_api"
require "forwardable"
require "dry/core/memoizable"
require_relative "functions"
require_relative "schema"

module Graphiti::OpenAPI
  class Generator
    extend Forwardable
    include Dry::Core::Memoizable

    def initialize(
                   root: Rails.root,
                   schema: root.join("public#{ApplicationResource.endpoint_namespace}").join("schema.json"),
                   jsonapi: root.join("public/schemas/jsonapi.json"),
                   template: root.join("config/openapi.yml"))
      @root = Pathname(root)
      @schema_path = schema
      @jsonapi_path = jsonapi
      @template_path = template
    end

    # @!attribute [r] root
    #   @return [Pathname]
    # @!attribute [r] schema
    #   @return [{String => Source}]
    attr_reader :root

    def schema
      Schema.new(schema_source.data)
    end

    def_instance_delegators :schema,
                            :endpoints, :resources, :types,
                            :resource

    def schema_source(path = @schema_path)
      Source.load(path)
    end

    def template_source(path = @template_path)
      Source.load(path, parse: YAML.method(:safe_load))
    end

    def paths
      @paths ||=
        endpoints.values.map(&:paths).inject(&:merge)
    end

    def to_openapi(format: :json)
      template = template_source.data
      data = {
        openapi: "3.0.1",
        servers: servers,
        tags: tags,
        paths: paths,
        components: {
          schemas: schemas,
          parameters: parameters,
          requestBodies: request_bodies,
          responses: responses,
          links: links,
        },
      }
      specification = Functions[:deep_merge][template, data]
      case format
      when :json
        specification
      when :yaml
        json = specification.to_json
        JSON.parse(json).to_yaml
      else
        raise ArgumentError, "Unknown format: `#{format.inspect}`"
      end
    end

    private

    def servers
      [{url: root_url, description: "#{Rails.env} server"}]
    end

    def root_url
      url_options = Rails.application.routes.default_url_options
      "#{url_options[:protocol]}://#{url_options[:host]}"
    end

    def tags
      resources.values.map do |resource|
        {
          name: resource.type,
          description: "#{resource.human} operations",
        }
      end
    end

    def request_bodies
      resources.values.each_with_object({}) do |resource, result|
        result[resource.type] = {
          required: true,
          content: {
            "application/vnd.api+json" => {schema: {"$ref": "#/components/schemas/#{resource.type}_request"}},
          # "application/xml" => {schema: {"$ref": "#/components/schemas/#{resource.type}_request"}},
          },
        }
      end
    end

    def responses
      resources.values.map(&:to_responses).inject(&:merge).compact
    end

    def links
      resources.values.map(&:to_links).inject(&:merge).compact
    end

    def schemas
      {types: {type: :string, enum: resources.values.map(&:type)}}
        .merge(resources.values.map(&:to_schema).inject(&:merge))
        .merge(jsonapi_definitions)
    end

    def parameters
      resources.values.map(&:to_parameters).inject(&:merge)
    end

    REWRITE_JSONAPI_SCHEMA = -> (text) do
      text
        .gsub("/definitions/", "/components/schemas/jsonapi_")
        .gsub(%r'"type": "null"', '"nullable": true')
      # .gsub(%r',\s*{\s*"type": "null"\s*}\s*', ', "nullable": true')
    end

    PROCESS_JSONAPI_SCHEMA = Source::DEFAULT_PROCESS >>
                             # Reject unsupported schema properties
                             Functions[:deep_reject_keys,
                                       %i[$schema additionalItems const contains dependencies id $id patternProperties propertyNames]
                             ]

    PREFIX_JSONAPI_DEFINITIONS = Functions[:map_keys, -> (key) { "jsonapi_#{key}" }]

    def jsonapi_source(path = @jsonapi_path)
      Source.load(path, rewrite: REWRITE_JSONAPI_SCHEMA, process: PROCESS_JSONAPI_SCHEMA)
    end

    def jsonapi_definitions
      defs = jsonapi_source.data[:definitions]
      defs[:jsonapi][:properties][:version][:example] = "1.0"

      # Provide meaningful linkages in examples
      variants = defs[:relationshipToOne].delete(:anyOf)
      variants = variants.keep_if { |item| item[:$ref] !~ /empty/ }
      defs[:relationshipToOne][:oneOf] = variants + [nullable: true]

      # Provide real types and id examples
      %i[resource linkage].each do |schema|
        defs[schema][:properties][:id] = {type: :string, example: rand(100).to_s}
        defs[schema][:properties][:type] = {'$ref': "#/components/schemas/types"}
      end

      # Use real resources in examples
      defs[:resource] = {
        oneOf: resources.values.map { |resource| {'$ref': "#/components/schemas/#{resource.type}_resource"} },
      }

      # Fix OpenAPI and JSON Schema differences
      defs[:relationshipLinks][:properties][:self].delete(:description)

      # Hide meta & links
      %i[meta links relationshipLinks].each do |schema|
        original = defs.delete(schema)
        defs[schema] = {oneOf: [{nullable: true}, original]}
      end

      # Remove unused elements
      %i[attributes empty].each { |schema| defs.delete(schema) }

      PREFIX_JSONAPI_DEFINITIONS[defs]
    end

    memoize :jsonapi_source, :jsonapi_definitions, :schema_source, :schema, :template_source, :root_url
  end
end
