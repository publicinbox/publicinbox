class MessagesController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def inbox
    messages = current_user.incoming_messages.order(:id => :desc).limit(20)
    render(:json => messages)
  end

  def outbox
    messages = current_user.outgoing_messages.order(:id => :desc).limit(20)
    render(:json => messages)
  end

  def create
    message = current_user.outgoing_messages.create!(message_params)

    if message.recipient_email.ends_with?('@publicinbox.net')
      message.recipient = User.find_by_email(message.recipient_email)
      message.save
    else
      Mailer.deliver_message(message)
    end

    redirect_to(root_path)
  end

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

  private

  def message_params
    params.require(:message).permit(:recipient_email, :subject, :body)
  end
end
