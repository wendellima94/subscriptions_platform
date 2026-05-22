Rails.application.routes.draw do
  root "home#index"

  get "up" => "rails/health#show", as: :rails_health_check

  get "/login", to: "sessions#new", as: :login
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy", as: :logout

  resources :plans, only: [ :index ]
  resources :subscriptions, only: [ :create ]

  resource :subscription, only: [ :show, :destroy ]
  resources :invoices, only: [] do
    post :pay, on: :member
  end

  namespace :admin do
    resources :plans
    resources :subscriptions, only: [ :index ]
    resources :invoices, only: [ :index ]
  end

  namespace :api do
    namespace :v1 do
      resources :plans, only: [ :index ]
      resources :subscriptions, only: [ :create ]

      namespace :me do
        resource :subscription, only: [ :show ]
      end

      resources :invoices, only: [] do
        post :pay, on: :member
      end
    end
  end
end
