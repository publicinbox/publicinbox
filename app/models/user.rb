class User < ActiveRecord::Base
  has_secure_password :validations => false

  has_many :identities
  has_many :outgoing_messages, :class_name => 'Message', :foreign_key => 'sender_id'
  has_many :incoming_messages, :class_name => 'Message', :foreign_key => 'recipient_id'

  strip_attributes

  def name
    self.real_name || self.user_name
  end

  def has_identity?(provider)
    self.identities.where(:provider => provider).any?
  end

  def messages
    Message.where('sender_id = ? or recipient_id = ?', self.id, self.id)
  end

  def create_message!(attributes)
    message = self.outgoing_messages.new(attributes)

    raise "You must specify a recipient." if !message.has_recipient?

    message.save!
    message
  end

  def delete_message!(message)
    if self == message.recipient
      message.recipient_id = nil
    elsif self == message.sender
      message.sender_id = nil
    else
      raise "You can't delete someone else's e-mail!"
    end

    # Since a message is sorta owned by two parties (sender + recipient),
    # "deleting" a message will really only unlink it from the current user (so
    # the other user can still see it). However, if both users have deleted it,
    # or only one user is a PublicInbox user and the other is external, then we
    # can delete it for real.
    if message.sender_id.nil? && message.recipient_id.nil?
      message.destroy!
    else
      message.save!
    end
  end

  validates :user_name, :format => { :with => /\A[0-9a-z_\.\-\+]+\Z/ }

  before_create :populate_email

  private

  def populate_email
    self.email = "#{self.user_name}@publicinbox.net"
  end
end
