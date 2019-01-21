require "rails"
require "responders"
require "graphiti"
require "webpacker"

module Graphiti
  module OpenAPI
    class Engine < ::Rails::Engine
      isolate_namespace Graphiti::OpenAPI

      initializer "graphiti.openapi.init" do
        Mime::Type.register "text/yaml", :yaml
      end
    end
  end
end
