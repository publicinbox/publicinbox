class Message < ActiveRecord::Base
  include HasUniqueToken

  belongs_to :sender, :class_name => 'User'
  belongs_to :recipient, :class_name => 'User'

  strip_attributes

  ##### BEGIN TEMPORARY MAILGUN_DATA-RELATED CODE #####

  serialize :mailgun_data, JsonSerializer

  DEFAULT_COLUMNS = self.columns.map(&:name) - ['mailgun_data']

  default_scope { select(DEFAULT_COLUMNS.join(', ')) }

  def get_mailgun_data
    @fetched_mailgun_data ||= Message.where(:id => self.id).select('mailgun_data').first.mailgun_data
  end

  def mailgun_attribute(name)
    get_mailgun_data.try(:[], name)
  end

  def mailgun_message_id
    mailgun_attribute('Message-ID')
  end

  ##### END TEMPORARY MAILGUN_DATA-RELATED CODE #####

  validates :recipient_email, :format => { :with => /\A[^@]+@\w[\w\.]+\w\Z/ }, :allow_nil => true

  before_create :populate_ids, :populate_emails

  def has_recipient?
    self.recipient_id.present? || self.recipient_email.present?
  end

  def internal_sender?
    self.sender_email.try(:ends_with?, '@publicinbox.net')
  end

  def internal_recipient?
    self.recipient_email.try(:ends_with?, '@publicinbox.net')
  end

  private

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
