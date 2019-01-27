Graphiti::OpenAPI::Engine.routes.draw do
  resources :specifications, only: :index, defaults: {format: :html}

  get "openapi.:format" => "specifications#index", defaults: {format: :json}, as: :openapi
  root to: "specifications#index", defaults: {format: :html}
end
