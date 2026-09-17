Rails.application.routes.draw do
  devise_for :users
  root "top#index"

  get "dashboard", to: "dashboard#show", as: :dashboard

  get "up" => "rails/health#show", as: :rails_health_check
end
