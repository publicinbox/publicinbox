require 'rest_client'

API_KEY = ENV['MAILGUN_API_KEY']
API_URL = "https://api:#{API_KEY}@api.mailgun.net/v2/publicinbox.net"

class Mailer
  def self.deliver_message!(message)
    response = RestClient.post("#{API_URL}/messages", {
      'from' => message.sender_email,
      'to' => message.recipient_email,
      'cc' => message.cc_list,
      'bcc' => message.bcc_list,
      'subject' => message.subject,
      'text' => message.body || '',
      'h:In-Reply-To' => message.external_source_id
    })

    puts "Response from sending message #{message.id}:"
    puts response

    # Parse the response to get this message's external_id. This is how we'll
    # know, when a new message comes in, whether it's a reply to an existing
    # message or not.
    response = JSON.parse(response)
    message.external_id = response['id']
    message.save!
  end
end
