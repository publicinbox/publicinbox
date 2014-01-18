class MessagesController < ApplicationController
  skip_before_filter :verify_authenticity_token

  include ApiHelper

  def index
    messages = current_user.messages.order(:id => :desc).limit(50)

    render(:json => {
      :user => render_user(current_user),
      :messages => messages.map { |message|
        render_message(message)
      },

      # Yeah... I don't feel great about this, but whatever.
      :subscription_key => Pusher.key
    })
  end

  def create
    message = current_user.create_message!(message_params)

    unless message.internal_recipient?
      Mailer.deliver_message!(message) unless Rails.env.development?
    end

    render(:json => render_message(message))

  rescue => ex
    puts "Error creating message: #{ex.inspect}"
    render(:text => ex.message, :status => 404)
  end

  def update
    message = Message.find(params[:id])

    message.opened_at = Time.now
    message.save!

    render(:json => render_message(message))

  rescue => ex
    puts "Error marking message opened: #{ex.inspect}"
    render(:text => ex.message, :status => 404)
  end

  def destroy
    message = Message.find(params[:id])
    current_user.delete_message!(message)
    render(:text => 'Message successfully deleted.')

  rescue => ex
    puts "Error deleting message: #{ex.inspect}"
    render(:text => ex.message, :status => 403)
  end

  def incoming
    message = Message.create_from_external!(params)

    puts "Publishing realtime message #{message.id} on channel '/#{message.recipient_email}'"
    Pusher[message.recipient_email].trigger('message', render_message(message))
    puts "Successfully published message #{message.id} on channel '/#{message.recipient_email}'"

    render(:text => 'OK')

  rescue => ex
    render(:text => ex.message, :status => 404)
  end

  private

  def message_params
    params.require(:message).permit(:external_source_id, :recipient_email, :subject, :body)
  end

  def render_user(user)
    {
      :id => user.id,
      :user_name => user.user_name,
      :real_name => user.real_name,
      :email => user.email,
      :bio => markdown(user.bio),
      :created_at => time_ago_in_words(user.created_at)
    }
  end

  def render_message(message)
    message_type = message.type_for_user(current_user)
    incoming = message_type == 'incoming'

    {
      :id => message.id,
      :type => message_type,
      :external_id => message.external_id,
      :sender_email => message.sender_email,
      :recipient_email => message.recipient_email,
      :display_email => incoming ? message.sender_email : message.recipient_email,
      :preposition => incoming ? 'From' : 'To',
      :reply_to => message.sender_email,
      :profile_image => profile_image(message.sender_email),
      :subject => message.subject,
      :body => markdown(message.body),
      :created_at => time_ago_in_words(message.created_at),
      :opened => !!message.opened_at
    }
  end
end
