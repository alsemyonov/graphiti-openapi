require "graphiti/open_api"
require_relative "struct"
require_relative "action"

module Graphiti::OpenAPI
  class EndpointData < Struct
    attribute :actions, Types::Hash.map(Types::Symbol, ActionData)

    def actions
      Actions.load(self)
    end

    memoize :actions
  end

  class Endpoint < EndpointData
    attribute :schema, Types::Any
    attribute :path, Types::Coercible::String

    def path
      __attributes__[:path].gsub(/^#{Regexp.escape(ApplicationResource.endpoint_namespace)}/, '')
    end

    def resource_path
      File.join(path.to_s, "{id}")
    end

    def paths
      {
        path => {
          parameters: parameters,
        }.merge(collection_actions.map(&:operation).inject(&:merge)),
        resource_path => {
          parameters: [{'$ref': "#/components/parameters/#{resource.type}_id"}] + parameters,
        }.merge(resource_actions.map(&:operation).inject(&:merge)),
      }
    end

    def parameters
      [].tap do |parameters|
        parameters << {'$ref': "#/components/parameters/#{type}_include"} if resource.relationships?
        parameters << {'$ref': "#/components/parameters/#{type}_sort"}
        parameters << {'$ref': "#/components/parameters/#{type}_fields"}
        resource.relationships.values.map do |relationship|
          relationship.resources.each do |resource|
            parameters << {'$ref': "#/components/parameters/#{resource.type}_fields"}
          end
        end
      end.uniq
    end

    def resource
      resource_actions.first.resource
    end

    def_instance_delegators :resource, :type

    def resource_actions
      actions.reject(&:collection?)
    end

    def collection_actions
      actions.select(&:collection?)
    end

    memoize :path, :resource_path, :paths, :parameters, :resource, :resource_actions, :collection_actions
  end

  class Endpoints < Hash
    def self.load(schema, data: schema.__attributes__[:endpoints])
      data.each_with_object({}) do |(path, data), result|
        result[path] = Endpoint.new(data.to_hash.merge(schema: schema, path: path))
      end
    end
  end
end
