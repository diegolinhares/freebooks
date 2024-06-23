::Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :web, path: "" do
    namespace :librarians do
      resources :dashboards, only: [:index]
      resources :sessions, only: [:new, :create]
      resource :sessions, only: [:destroy]
      resources :books, only: [:index, :new, :create, :edit, :update, :destroy]
      resources :borrowings, only: [:update]
      resources :users, only: [:index] do
        resources :borrowings, only: [:index], module: "users"
      end

      root "dashboards#index"
    end

    namespace :members do
      resources :sessions, only: [:new, :create]
      resource :sessions, only: [:destroy]
      resources :books, only: [:index, :new, :create, :edit, :update, :destroy]

      root "books#index"
    end
  end
end
