Rails.application.routes.draw do
  root 'home#index'

  post '/login'    => 'home#login'
  post '/register' => 'home#register'
  get '/logout'    => 'home#logout'

  post '/messages/incoming' => 'messages#incoming'

  resources :users
  resources :messages

  faye_server '/realtime', :timeout => 25 do
    map '/messages' => RealtimeMessagesController
  end
end
