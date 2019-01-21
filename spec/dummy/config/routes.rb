Rails.application.routes.draw do
  scope path: ApplicationResource.endpoint_namespace, defaults: {format: :jsonapi} do
    resources :articles

    mount Graphiti::OpenAPI::Engine => "/"
  end
end
