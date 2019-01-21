require "graphiti/open_api"
require_relative "struct"
require_relative "resource"
require_relative "endpoint"
require_relative "type"

module Graphiti::OpenAPI
  class Schema < Struct
    attribute :resources, Types.Array(ResourceData)
    attribute :endpoints, Types::Hash.map(Types::Coercible::String, EndpointData)
    attribute :types, Types::Hash.map(Types::Symbol, TypeData)

    # @return [Resources{String => Resource}]
    def resources
      Resources.load(self)
    end

    # @return [Endpoints{String => Endpoint}]
    def endpoints
      Endpoints.load(self)
    end

    # @return [{Symbol => Type}]
    def types
      __attributes__[:types].each_with_object({}) do |(id, type), result|
        result[id] = Type.new(type.to_hash.merge(name: id))
      end
    end

    memoize :resources, :endpoints, :types
  end
end
