require "rails_helper"

module Graphiti::OpenAPI
  RSpec.describe "Specifications", type: :request do
    include Engine.routes.url_helpers

    describe "GET /specifications" do
      it "shows Swagger UI" do
        get specifications_path
        expect(response).to have_http_status(200)
      end

      it "generates JSON OpenAPI specification" do
        get specifications_path(format: :json)
        expect(response).to have_http_status(200)
      end

      it "generates YAML OpenAPI specification" do
        get specifications_path(format: :yaml)
        expect(response).to have_http_status(200)
      end
    end
  end
end
