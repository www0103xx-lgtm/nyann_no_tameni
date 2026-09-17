Rails.application.routes.draw do
  devise_for :users
  root "top#index"

  get "dashboard", to: "dashboard#show", as: :dashboard

  resources :diet_challenges, only: %i[new create]

  get "up" => "rails/health#show", as: :rails_health_check
end
