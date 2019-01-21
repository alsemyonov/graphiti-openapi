Graphiti::OpenAPI::Engine.routes.draw do
  resources :specifications, only: :index, defaults: {format: :html}

  root to: "specifications#index", defaults: {format: :html}
end
