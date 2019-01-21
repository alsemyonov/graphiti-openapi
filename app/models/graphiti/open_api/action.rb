require "graphiti/open_api"
require_relative "struct"
require_relative "parameters"

module Graphiti::OpenAPI
  class ActionData < Struct
    attribute :resource, Types::String
  end

  class Action < ActionData
    include Parameters

    METHODS_MAP = Hash.new do |hash, key|
      hash[key] = key
    end.merge(
      index: :get,
      show: :get,
      create: :post,
      update: :put,
      destroy: :delete,
    )

    SUMMARIES_MAP = Hash.new do |hash, key|
      hash[key] = "#{key.capitalize} resource"
    end.merge(
      index: "List resources",
      show: "Fetch resource",
      create: "Create resource",
      update: "Update resource",
      destroy: "Destroy resource",
    )

    OPERATIONS_MAP = Hash.new do |hash, key|
      hash[key] = key
    end.merge(
      index: :list,
      show: :get,
      destroy: :delete,
    )

    attribute :endpoint, Types::Any
    attribute :action, Types::Symbol

    def_instance_delegators :endpoint, :schema

    def resource
      schema.resources[attributes[:resource]]
    end

    def_instance_delegators :resource, :type, :model_name

    def collection?
      %i[index create].include?(action)
    end

    def resource?
      !collection?
    end

    def read?
      %i[index show].include?(action)
    end

    def modify?
      %i[create update].include?(action)
    end

    def method
      METHODS_MAP[action]
    end

    def summary
      SUMMARIES_MAP[action].gsub(/\bresources\b/, type.humanize).gsub(/\bresource\b/, type.singularize.humanize)
    end

    def operation_id
      "#{OPERATIONS_MAP[action]}_#{action == :index ? model_name.plural : model_name.singular}".camelize(:lower)
    end

    def operation
      {method => operation_description}
    end

    def operation_description
      {
        operationId: operation_id,
        summary: summary,
        tags: tags,
        responses: responses,
      }.tap do |desc|
        desc[:requestBody] = {'$ref': "#/components/requestBodies/#{resource.type}"} if modify?
      end
    end

    def delete?
      action == :destroy
    end

    memoize :collection?, :method, :resource, :operation

    private

    def tags
      [type]
    end

    def responses
      {}.tap do |result|
        result[200] = {'$ref': "#/components/responses/#{resource.type}_200#{"_collection" if collection?}"} if %i[index show update].include?(action)
        result[200] = {'$ref': "#/components/responses/200"} if delete?
        result[201] = {'$ref': "#/components/responses/#{resource.type}_201"} if action == :create
        result[202] = {'$ref': "#/components/responses/202"} if modify? || delete?
        result[204] = {'$ref': "#/components/responses/204"} if modify? || delete?
        result[401] = {"$ref": "#/components/responses/401"} # if authentication?
        result[403] = {"$ref": "#/components/responses/403"} # if authorization?
        result[404] = {"$ref": "#/components/responses/404"} unless collection?
        result[403] = {"$ref": "#/components/responses/409"} if modify?
        result[422] = {"$ref": "#/components/responses/422"} if modify?
      end
    end
  end

  class Actions < Hash
    def self.load(endpoint, data: endpoint.__attributes__[:actions])
      data.map do |action, data|
        Action.new(data.to_hash.merge(endpoint: endpoint, action: action))
      end
    end
  end
end
