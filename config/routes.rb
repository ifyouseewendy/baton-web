Rails.application.routes.draw do
  root 'data#show'

  resources :data do
    collection do
      get :get_hourly
    end
  end
end
