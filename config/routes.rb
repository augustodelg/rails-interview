Rails.application.routes.draw do
  root 'todo_lists#index'
  
  # Main HTML routes with Hotwire
  resources :todo_lists, path: :todolists do
    member do
      post 'complete_all'
    end
    
    resources :todo_list_items, path: :items do
      member do
        patch 'complete'
        patch 'toggle'
      end
    end
  end
  
  # Keep API routes for backward compatibility if needed
  namespace :api do
    resources :todo_lists, only: %i[index], path: :todolists do
      member do
        post 'complete_all'
      end

      resources :todo_list_items, only: %i[create update destroy], path: :items do
        member do
          put 'complete'
        end
      end
    end
  end
end
