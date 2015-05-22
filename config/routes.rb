Rails.application.routes.draw do
  root to: 'projects#index'

  resources :users

  resources :projects do
    resources :stages do
      resources :tasks, only: [] do
        resources :steps, only: [] do
          member do
            post  :run
            get   :send_file
          end
        end
      end
    end

    member do
      get :send_file
    end
  end

  get '/resources/:recipe/:id/:direction/:filename' => 'projects#send_file'
end
