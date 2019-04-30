Rails.application.routes.draw do
  resources :books
  resource :activities, only: [:create]

  root to: 'books#index'
end
