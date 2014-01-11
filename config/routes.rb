Rails.application.routes.draw do
  root 'home#index'

  match '/login'    => 'home#login',    :via => [:get, :post]
  match '/register' => 'home#register', :via => [:get, :post]
  match '/logout'   => 'home#logout',   :via => [:get, :post]

  get '/inbox' => 'messages#inbox'
  get '/outbox' => 'messages#outbox'
  post '/messages/incoming' => 'messages#incoming'

  resources :messages
end
