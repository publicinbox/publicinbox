class MessagesController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def incoming
    from    = params['sender']
    to      = params['recipient']
    subject = params['subject']
    body    = params['body-plain']

    sender = User.find_by_email(from)
    recipient = User.find_by_email(to)

    Message.create!({
      :sender => sender,
      :sender_email => from,
      :recipient => recipient,
      :recipient_email => to,
      :subject => subject,
      :body => body
    })

    render :text => "OK"
  end
end
