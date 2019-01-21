require "graphiti/open_api/version"
require "active_support"

module Graphiti
  module OpenAPI
    class Error < StandardError
    end
  end
end

ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym "API"
end

require "graphiti/open_api/engine"
