::Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      namespace :librarians do
        resources :books, only: [:index, :create, :update, :destroy]
      end

      namespace :members do
        resource :sessions, only: [:create]
        resources :borrowings, only: [:index]
        resources :books, only: [:index] do
          resources :borrowings, only: [:create]
        end
      end
    end
  end

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
      resources :borrowings, only: [:index]
      resources :books, only: [:index] do
        resources :borrowings, only: [:create]
      end

      root "books#index"
    end
  end
end
