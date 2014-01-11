class MessagesController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def incoming
    sender  = params['from']
    subject = params['subject']

    puts "\n\n\nE-mail received from Mailgun:\n\n\n"
    puts "Sender: #{sender}, subject: #{subject}"
    puts "params: #{params.inspect}\n\n\n"

    render :text => "OK"
  end
end
