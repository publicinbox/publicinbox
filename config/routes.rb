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
  # I've deleted the faye-related code elsewhere in the project; to get it back,
  # check out commit 4804d95 (last commit before deleting everything).
  #
  # THEN, to re-enable:
  # - Uncomment the lines below (duh)
  # - Uncomment the `config.middleware.delete Rack::Lock` line in application.rb
  # - Uncomment the RealtimeMessagesController.publish call in MessagesController#incoming
  # - Uncomment the lines in messages.js that utilize Faye.Client
  #
  # To be clear, eventually I *would* like to use faye-rails rather than an
  # external service (at the moment I've switched to Pusher), because it would
  # be nice to not have any limits. And since Heroku supports WebSockets now...
  # basically, this *should* be possible. I just couldn't get it to work, hence
  # the (temporary) switch.
  #
  # faye_server '/realtime', :timeout => 25 do
  #   map '/messages/**' => RealtimeMessagesController
  # end
end
