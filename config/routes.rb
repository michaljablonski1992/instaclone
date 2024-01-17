Rails.application.routes.draw do
  root "home#index"
  
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
  
  resources :posts

  post 'toggle_like', to:  'likes#toggle_like', as: :toggle_like

  resources :comments, only: [:create, :destroy]
end
