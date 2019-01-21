# frozen_string_literal: true

jsonapi_schema = 'public/schemas/jsonapi.json'

namespace :graphiti do
  namespace :openapi do
    desc "Copy over the assets pack"
    task install: %I[environment run_installer]

    task :run_installer => jsonapi_schema do
      installer_template = File.expand_path("../templates/installer.rb", __dir__)
      system "#{RbConfig.ruby} ./bin/rails app:template LOCATION=#{installer_template}"
    end

    task generate: :environment do
      generator = Graphiti::OpenAPI::Generator.new
      api = Rails.root.join("public#{ApplicationResource.endpoint_namespace}")
      api.join("openapi.json").write(generator.to_openapi.to_json)
      api.join("openapi.yaml").write(generator.to_openapi(format: :yaml))
    end
  end
end

namespace :assets do
  task precompile: "graphiti:openapi:generate"
end

file jsonapi_schema do |t|
  require 'open-uri'

  # mkdir_p(File.dirname(t.name))
  File.write(t.name, open('http://jsonapi.org/schema').read)
end
