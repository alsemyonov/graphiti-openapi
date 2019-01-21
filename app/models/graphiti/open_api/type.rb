require "graphiti/open_api"
require "graphiti/types"
require_relative "struct"

module Graphiti::OpenAPI
  class TypeData < Struct
    attribute :kind, Types::String
    attribute :description, Types::String
  end

  class Type < TypeData
    TYPES_MAP = Hash.new do |hash, type|
      hash[type] = {type: type}
    end.merge(
      hash: {type: :object, additionalProperties: true},
      datetime: {type: :string, format: :'date-time'},
      date: {type: :string, format: :date},
      time: {type: :string, format: :'date-time'},
      inet: {type: :string, format: :ipv4},
    )

    attribute :name, Types::Symbol

    def dry_type
      Graphiti::Types[name]
    end

    def canonical_name
      Graphiti::Types.name_for(name)
    end

    def to_schema
      TYPES_MAP[canonical_name].dup
    end

    memoize :dry_type, :canonical_name
  end
end
