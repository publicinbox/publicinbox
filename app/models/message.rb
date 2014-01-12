class Message < ActiveRecord::Base
  belongs_to :sender, :class_name => 'User'
  belongs_to :recipient, :class_name => 'User'

  before_create :populate_emails

  def populate_emails
    self.sender_email ||= "#{self.sender.user_name}@publicinbox.net" if self.sender_id.present?
    self.recipient_email ||= "#{self.recipient.user_name}@publicinbox" if self.recipient_id.present?
  end
end
