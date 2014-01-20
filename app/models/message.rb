class Message < ActiveRecord::Base
  include HasUniqueToken

  belongs_to :sender, :class_name => 'User'
  belongs_to :recipient, :class_name => 'User'

  strip_attributes

  ##### BEGIN TEMPORARY MAILGUN_DATA-RELATED CODE #####

  serialize :mailgun_data, JsonSerializer

  DEFAULT_COLUMNS = self.columns.map(&:name) - ['mailgun_data']

  def get_mailgun_data
    @fetched_mailgun_data ||= Message.where(:id => self.id).select('mailgun_data').first.mailgun_data
  end

  def mailgun_attribute(name)
    get_mailgun_data.try(:[], name)
  end

  def mailgun_message_id
    mailgun_attribute('Message-Id')
  end

  def mailgun_reply_to
    mailgun_attribute('In-Reply-To')
  end

  ##### END TEMPORARY MAILGUN_DATA-RELATED CODE #####

  default_scope { where('archived_at IS NULL').select(DEFAULT_COLUMNS.join(', ')) }

  validates :recipient_email, :format => { :with => /\A[^@]+@\w[\w\.]+\w\Z/ }, :allow_nil => true

  before_create :populate_ids, :populate_emails, :populate_thread_id

  def self.create_from_external!(message_data)
    from    = message_data['sender']
    to      = message_data['recipient']
    subject = message_data['subject']
    body    = message_data['body-plain']

    sender = User.find_by(:email => from)
    recipient = User.find_by(:email => to)

    raise 'No such user' if recipient.nil?

    external_id = message_data['Message-Id']
    external_source_id = message_data['In-Reply-To']

    Message.create!({
      :external_id => external_id,
      :external_source_id => external_source_id,
      :sender => sender,
      :sender_email => from,
      :recipient => recipient,
      :recipient_email => to,
      :subject => subject,
      :body => body,

      # This is really just temporary; for a while it will be helpful to store
      # this so I can go back and look at stuff
      :mailgun_data => message_data
    })
  end

  def archive!
    self.archived_at = Time.now
    self.save!
  end

  def thread
    Message.where(:thread_id => self.thread_id).order(:id => :asc)
  end

  def thread_before
    thread.where('id <= ?', self.id)
  end

  def thread_after
    thread.where('id >= ?', self.id)
  end

  def type_for_user(user)
    user == self.recipient ? 'incoming' : 'outgoing'
  end

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

  def populate_thread_id
    # If external_source_id is present, use that to find the associated message
    # and assign this one to the same thread.
    self.thread_id ||= self.external_source_id.present? &&
      Message.find_by(:external_id => self.external_source_id).try(:thread_id)

    # Otherwise, this is an original message and so it creates a new thread,
    # which we will elegantly and ingeniously assign to its unique_token.
    self.thread_id ||= self.unique_token
  end
end
