require 'rest_client'

API_KEY = ENV['MAILGUN_API_KEY']
API_URL = "https://api:#{API_KEY}@api.mailgun.net/v2/publicinbox.net"

class Mailer
  def self.deliver_message!(message)
    RestClient.post("#{API_URL}/messages", {
      :from => message.sender_email,
      :to => message.recipient_email,
      :subject => message.subject,
      :text => message.body
    })
  end
end
