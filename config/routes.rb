Rails.application.routes.draw do
  devise_for :users
  root "top#index"

  get "dashboard", to: "dashboard#show", as: :dashboard

  resources :diet_challenges, only: %i[new create]
  resources :weight_records, only: %i[index new create edit update]

  get "up" => "rails/health#show", as: :rails_health_check
end
