require_dependency "graphiti/open_api/application_controller"

module Graphiti::OpenAPI
  class SpecificationsController < ApplicationController
    def index
      respond_to do |format|
        format.html do
          return render 'redoc' if params[:skin] == 'redoc'
        end
        format.json { render json: generator.to_openapi }
        format.yaml { render text: generator.to_openapi(format: :yaml), layout: nil }
      end
    end

    private

    def generator
      @generator ||= Generator.new
    end

    helper_method :generator
  end
end
