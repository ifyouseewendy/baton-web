Rails.application.routes.draw do
  resources :users

  resources :projects do
    resources :stages do
      resources :tasks, only: [] do
        resources :steps, only: [] do
          member do
            post 'run'
          end
        end
      end
    end
  end
end
