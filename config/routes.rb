Rails.application.routes.draw do
  resources :users

  resources :projects do
    resources :stages do
    end
  end
end
