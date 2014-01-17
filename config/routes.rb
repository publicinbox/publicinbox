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

  # Temporarily disabling this because it doesn't work anyway, and I think
  # deleting the Rack::Lock middleware (to prevent deadlocks) may have broken
  # some other stuff.
  #
  # To re-enable:
  # - Uncomment the lines below (duh)
  # - Uncomment the `config.middleware.delete Rack::Lock` line in application.rb
  # - Uncomment the RealtimeMessagesController.publish call in MessagesController#incoming
  # - Uncomment the lines in messages.js that utilize Faye.Client
  #
  # faye_server '/realtime', :timeout => 25 do
  #   map '/messages/**' => RealtimeMessagesController
  # end
end
