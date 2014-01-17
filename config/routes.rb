Rails.application.routes.draw do
  root 'home#index'

  post '/login'    => 'home#login'
  post '/register' => 'home#register'
  get '/logout'    => 'home#logout'

  get  '/messages/test'     => 'messages#test' if Rails.env.development?
  post '/messages/incoming' => 'messages#incoming', :as => :incoming_message

  resources :users
  resources :messages
  resources :blog

  get '/blog/*permalink' => 'blog#show'

  faye_server '/realtime', :timeout => 25 do
    map '/messages/**' => RealtimeMessagesController
  end
end
