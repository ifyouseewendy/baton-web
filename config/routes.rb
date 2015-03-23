Rails.application.routes.draw do
  root 'data#index'

  resources :data do
    collection do
      get :get_hourly
    end
  end
end
