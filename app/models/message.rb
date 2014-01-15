class Message < ActiveRecord::Base
  belongs_to :sender, :class_name => 'User'
  belongs_to :recipient, :class_name => 'User'

  before_create :populate_ids, :populate_emails

  def populate_ids
    if self.recipient_id.nil? && self.recipient_email =~ /@publicinbox\.net$/
      recipient_name = self.recipient_email.chomp('@publicinbox.net')
      self.recipient_id ||= User.find_by(:user_name => recipient_name).try(:id)
    end
  end

  def populate_emails
    self.sender_email ||= "#{self.sender.user_name}@publicinbox.net" if self.sender_id.present?
    self.recipient_email ||= "#{self.recipient.user_name}@publicinbox.net" if self.recipient_id.present?
  end
end
