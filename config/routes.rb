Rails.application.routes.draw do
  devise_for :users
  # get "homes/index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resources :groups, only: [:create, :show, :index, :destroy]

  resources :groups do
    resources :messages, only: [:index, :create]
    resources :participants do
      resources :wishlists
    end
  end

  resources :items, only: [:index, :show] do 
    collection do 
      get :filters
    end 
  end 
  resources :wishlists, only: [:show, :create, :update]

  get '/group_generator', to: 'groups#group_generator'
  
  resources :participants do
    member do
      get 'my_drawn_name'
      post 'my_drawn_name'
    end
  end

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "homes#index"
end
