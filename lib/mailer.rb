require 'rest_client'

API_KEY = ENV['MAILGUN_API_KEY']
API_URL = "https://api:#{API_KEY}@api.mailgun.net/v2/publicinbox.net"

class Mailer
  def self.deliver_message!(message)
    request_data = {
      'from' => message.sender_email,
      'to' => message.recipient_email,
      'subject' => message.subject,
      'text' => message.body || '[No content]',
      'html' => message.body_html || '',
      'h:In-Reply-To' => message.external_source_id
    }

    request_data['cc'] = message.cc_list if message.cc_list.present?
    request_data['bcc'] = message.bcc_list if message.bcc_list.present?

    response = RestClient.post("#{API_URL}/messages", request_data)

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
