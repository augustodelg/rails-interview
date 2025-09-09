Rails.application.routes.draw do
  namespace :api do
    resources :todo_lists, only: %i[index], path: :todolists do      
      resources :todo_list_item, only: %i[create update destroy], path: :items do
        member do
          put 'complete'
        end
      end
      
    end
  end

  resources :todo_lists, only: %i[index new], path: :todolists
end
