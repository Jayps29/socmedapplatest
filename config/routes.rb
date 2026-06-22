Rails.application.routes.draw do
  get "notifications/index"
  get "users/index"
  get "profiles/show"
  root "home#index"
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get "/profile/:id", to: "profiles#show", as: :profile
  resources :users, only: [ :index ]
  resources :posts, only: [ :create, :destroy, :edit, :update, :show ] do
    member do
      get :comments
    end
  end
  resources :comments, only: [ :create, :destroy, :edit, :update ]
  resources :likes, only: [ :create, :destroy ]
  resources :follows, only: [ :create, :destroy ] do
    delete :remove_follower, on: :member
  end
  resources :friend_requests,
          only: [ :create, :update, :destroy ]
  resources :friendships, only: [ :destroy ]

  mount ActionCable.server => "/cable"


# config/routes.rb

resources :users do
  collection do
    get :search
  end
end

resources :notifications, only: [ :index ] do
  collection do
    get :dropdown
    patch :mark_read
  end
end
  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
