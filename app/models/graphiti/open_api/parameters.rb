require "graphiti/open_api"

module Graphiti::OpenAPI
  module Parameters
    def parameter(name, desc: nil, **options)
      options.merge(name: name).tap do |parameter|
        parameter[:description] = desc if desc
      end
    end

    def query_parameter(name, **options)
      parameter(name, in: :query, **options)
    end

    def path_parameter(name, required: true, **options)
      parameter(name, in: :path, required: required, **options)
    end

    def array_enum(enum, type: :string, uniq: true)
      {
        type: :array,
        items: {
          type: type,
          enum: enum,
          uniqueItems: uniq,
        },
      }
    end
  end
end
