::Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :web, path: "" do
    namespace :librarians do
      resources :sessions, only: [:new, :create]
      resources :books, only: [:index, :new, :create, :edit, :update, :destroy]

      root "sessions#new"
    end
  end
end
