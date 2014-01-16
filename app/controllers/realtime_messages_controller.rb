class RealtimeMessagesController < FayeRails::Controller
  channel '/messages' do
    subscribe do
      puts "Client subscribed to the 'messages' route"
    end
  end
end
