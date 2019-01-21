require "graphiti/open_api"
require_relative "struct"
require_relative "functions"

module Graphiti::OpenAPI
  class Source < Struct
    DEFAULT_REWRITE = -> (text) { text }
    DEFAULT_PARSE = JSON.method(:parse)
    DEFAULT_PROCESS = Functions[:deep_symbolize_keys]

    attribute :name, Types::Coercible::String
    attribute :path, Types::Pathname
    attribute :data, Types::Hash

    def self.load(path, name: path.basename, rewrite: DEFAULT_REWRITE, process: DEFAULT_PROCESS, parse: DEFAULT_PARSE)
      text = rewrite.(path.read)
      parsed = parse.(text)
      data = process.(parsed)

      new(
        name: name,
        path: path,
        data: data,
      )
    end
  end
end
