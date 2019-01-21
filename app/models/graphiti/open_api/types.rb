require "graphiti/open_api"
require "dry-types"

module Graphiti::OpenAPI
  module Types
    include Dry::Types.module

    Pathname = Types.Constructor(::Pathname, Kernel.method(:Pathname))
  end
end
