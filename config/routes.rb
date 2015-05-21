Rails.application.routes.draw do
  resources :users

  resources :projects do
    resources :stages do
      resources :tasks, only: [] do
        resources :steps, only: [] do
          member do
            post 'run'
            get :file
          end
        end
      end
    end
  end

  get '/resources/uploads/step/file/:id/:filename' => 'steps#file'
end
