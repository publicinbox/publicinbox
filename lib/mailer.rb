require 'rest_client'

API_KEY = ENV['MAILGUN_API_KEY']
API_URL = "https://api:#{API_KEY}@api.mailgun.net/v2/publicinbox.net"

class Mailer
  def self.deliver_message!(message)
    response = RestClient.post("#{API_URL}/messages", {
      'from' => message.sender_email,
      'to' => message.recipient_email,
      'subject' => message.subject,
      'text' => message.body || '',
      'h:In-Reply-To' => message.thread_id
    })

    puts "Response from sending message #{message.id}:"
    puts response

    # If a message doesn't already have a thread_id, then it's the first message
    # of a thread. All subsequent messages that are part of this thread should
    # have the 'In-Reply-To' header set to the same thread_id.
    if message.thread_id.nil?
      response = JSON.parse(response)
      message.thread_id = response['id']
      message.save!
    end
  end
end
