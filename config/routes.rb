Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      devise_scope :user do
        post 'sign_up', to: 'registrations#create'
        post 'sign_in', to: 'sessions#create'
        delete 'log_out', to: 'sessions#destroy'
      end

      post 'facebook', to: 'users#facebook'
      resources :books, only: %i[index show] do
        resources :reviews, only: %i[index show create update destroy]
      end
    end
  end
end
