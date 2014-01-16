class MessagesController < ApplicationController
  skip_before_filter :verify_authenticity_token

  include ApiHelper

  def index
    inbox  = current_user.incoming_messages.order(:id => :desc).limit(20)
    outbox = current_user.outgoing_messages.order(:id => :desc).limit(20)

    incoming_messages = inbox.map(&method(:render_incoming_message))
    outgoing_messages = outbox.map(&method(:render_outgoing_message))

    render(:json => {
      :inbox => incoming_messages,
      :outbox => outgoing_messages
    })
  end

  def create
    message = current_user.create_message!(message_params)

    unless message.internal_recipient?
      Mailer.deliver_message!(message)
    end

    render(:json => render_outgoing_message(message))

  rescue => ex
    render(:text => ex.message, :status => 404)
  end

  def destroy
    message = Message.find(params[:id])
    current_user.delete_message!(message)
    render(:text => 'Message successfully deleted.')

  rescue => ex
    render(:text => ex.message, :status => 403)
  end

  def incoming
    from    = params['sender']
    to      = params['recipient']
    subject = params['subject']
    body    = params['body-plain']

    sender = User.find_by_email(from)
    recipient = User.find_by_email(to)

    message = Message.create!({
      :sender => sender,
      :sender_email => from,
      :recipient => recipient,
      :recipient_email => to,
      :subject => subject,
      :body => body
    })

    RealtimeMessagesController.publish('/messages', render_incoming_message(message))

    render(:text => 'OK')
  end

  private

  def message_params
    params.require(:message).permit(:recipient_email, :subject, :body)
  end

  def render_incoming_message(message)
    {
      :id => message.id,
      :sender_email => message.sender_email,
      :reply_to => message.sender_email,
      :profile_image => profile_image(message.sender_email),
      :subject => message.subject,
      :body => markdown(message.body),
      :created_at => time_ago_in_words(message.created_at)
    }
  end

  def render_outgoing_message(message)
    {
      :id => message.id,
      :recipient_email => message.recipient_email,
      :reply_to => message.recipient_email,
      :profile_image => profile_image(message.recipient_email),
      :subject => message.subject,
      :body => markdown(message.body),
      :created_at => time_ago_in_words(message.created_at)
    }
  end
end
