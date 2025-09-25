Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  scope :api do

    namespace :auth do
      post 'login', to: 'auth#login'
      post 'register', to: 'auth#register'
    end

    resources :users
    resources :products

    resources :carts do
      member do
        post 'insert/:product_id', to: 'carts#insert_product'
        delete 'remove/:product_id', to: 'carts#remove_product'
        delete 'remove-all-products', to: 'carts#remove_all_products'
        post '/checkout', to: 'carts#checkout'
      end
    end
    
    get '/cart/user/:user_id', to: 'carts#find_user_cart'
  end
end
