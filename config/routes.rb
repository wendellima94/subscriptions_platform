Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

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
