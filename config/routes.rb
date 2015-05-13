Rails.application.routes.draw do
  resources :users

  resources :projects do
  end
end
