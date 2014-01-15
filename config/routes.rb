Rails.application.routes.draw do
  root 'home#index'

  match '/login'    => 'home#login',    :via => [:get, :post]
  match '/register' => 'home#register', :via => [:get, :post]
  match '/logout'   => 'home#logout',   :via => [:get, :post]

  post '/messages/incoming' => 'messages#incoming'

  resources :users
  resources :messages
end
