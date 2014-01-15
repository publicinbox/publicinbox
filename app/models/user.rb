class User < ActiveRecord::Base
  has_secure_password

  has_many :incoming_messages, :class_name => 'Message', :foreign_key => 'recipient_id'
  has_many :outgoing_messages, :class_name => 'Message', :foreign_key => 'sender_id'

  strip_attributes

  def self.find_by_email(email)
    name = email.split('@', 2).first
    find_by(:user_name => name)
  end

  def name
    self.real_name || self.user_name
  end

  before_create :populate_email

  private

  def populate_email
    self.email = "#{self.user_name}@publicinbox.net"
  end
end
