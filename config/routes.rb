require 'sidekiq/web'
Sidekiq::Web.use Rack::Auth::Basic do |username, password|
  ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(Rails.application.credentials.sidekiq[:username])) &
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(Rails.application.credentials.sidekiq[:password]))
end 

Rails.application.routes.draw do
  mount Sidekiq::Web => "/sidekiq"

  root "home#index"
  get :discover, to: 'home#discover', as: :discover
  
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    omniauth_callbacks: 'users/omniauth_callbacks'
  }
  
  resources :posts
  post 'toggle_like', to:  'likes#toggle_like', as: :toggle_like
  resources :comments, only: [:create, :destroy]
  resources :users, only: [:show, :index]
  resources :suggestions, only: [:index]


  # follows
  post :follow, to: 'follows#follow', as: :follow
  delete :unfollow, to: 'follows#unfollow', as: :unfollow
  delete :cancel_request, to: 'follows#cancel_request', as: :cancel_request
  post :accept_follow, to: 'follows#accept_follow', as: :accept_follow
  delete :decline_follow, to: 'follows#decline_follow', as: :decline_follow
end
