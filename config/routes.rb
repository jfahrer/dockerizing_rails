Rails.application.routes.draw do
  resources :todos, except: [:new, :edit, :show]
  resources :archived_todos, only: [:create]
  resources :activities, only: [:index]

  root to: 'todos#index'
end
