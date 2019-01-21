require "graphiti/open_api"
require_relative "struct"

module Graphiti::OpenAPI
  class RelationshipData < Struct
    attribute :type, Types::String
    attribute :description, Types::String.optional
    attribute? :resource, Types::String.optional
    attribute? :resources, Types.Array(Types::String).default([])
  end

  class Relationship < RelationshipData
    attribute :origin, Types::Any
    attribute :name, Types::Symbol

    def_instance_delegator :origin, :schema

    def resource
      return unless __attributes__[:resource]
      schema.resources[__attributes__[:resource]]
    end

    def resources
      return [resource] if __attributes__[:resources].empty?
      __attributes__[:resources].map { |resource| schema.resources[resource] }
    end

    def to_schema
      {
        name => {
          type: :object,
          properties: {
            links: {"$ref": "#/components/schemas/jsonapi_relationshipLinks"},
            data: {'$ref': "#/components/schemas/#{jsonapi_relationship}"},
            meta: {"$ref": "#/components/schemas/jsonapi_meta"},
          },
        },

      }
    end

    def jsonapi_relationship
      case type
      when /belongs_to/, "has_one"
        "jsonapi_relationshipToOne"
      else
        "jsonapi_relationshipToMany"
      end
    end

    memoize :resource, :resources
  end

  class Relationships < Hash
    def self.load(resource, data = resource.__attributes__[:relationships])
      data.each_with_object(new) do |(name, data), result|
        result[name] = Relationship.new(data.to_hash.merge(name: name, origin: resource))
      end
    end

    def resources
      values.map(&:resources).flatten.uniq.compact
    end
  end
end
