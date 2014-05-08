# == Schema Information
#
# Table name: messages
#
#  id                 :integer          not null, primary key
#  unique_token       :string(255)
#  sender_id          :integer
#  sender_email       :string(255)
#  recipient_id       :integer
#  recipient_email    :string(255)
#  cc_list            :text
#  bcc_list           :text
#  thread_id          :string(255)
#  external_id        :string(255)
#  external_source_id :string(255)
#  subject            :string(255)
#  body               :text
#  body_html          :text
#  opened_at          :datetime
#  archived_at        :datetime
#  created_at         :datetime
#  updated_at         :datetime
#  mailgun_data       :text
#  display_in_iframe  :boolean          default(FALSE)
#  source_id          :integer
#

class Message < ActiveRecord::Base
  include HasUniqueToken

  # Allow messages to be associated w/ source by token, not just ID
  attr_accessor :source_token

  belongs_to :source, :class_name => 'Message'
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

  before_create :populate_ids, :populate_emails, :populate_source_id,
    :populate_thread_id, :format_cc_and_bcc, :parse_html

  def self.create_from_external!(message_data)
    from    = message_data['sender']
    to      = message_data['recipient']
    subject = message_data['subject']
    body    = message_data['stripped-text']
    html    = message_data['stripped-html']

    sender = User.find_by(:email => from)
    recipient = User.find_by(:email => to)

    raise "No such user: #{to}" if recipient.nil?

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
      :body_html => html,

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

  def populate_source_id
    if self.source_id.nil? && self.source_token.present?
      self.source = Message.find_by(:unique_token => self.source_token)
    end
  end

  def populate_thread_id
    # If source_id is present, use that to find the associated message and
    # assign this one to the same thread.
    self.thread_id ||= self.source_id.present? &&
      Message.find_by(:id => self.source_id).try(:thread_id)

    # Otherwise, if external_source_id is present, try linking that to another
    # message's external_id.
    self.thread_id ||= self.external_source_id.present? &&
      Message.find_by(:external_id => self.external_source_id).try(:thread_id)

    # Otherwise, this is an original message and so it creates a new thread,
    # which we will elegantly and ingeniously assign to its unique_token.
    self.thread_id ||= self.unique_token
  end

  def format_cc_and_bcc
    self.cc_list = self.cc_list.split(/[,\s]+/).join(',') if self.cc_list.present?
    self.bcc_list = self.bcc_list.split(/[,\s]+/).join(',') if self.bcc_list.present?
  end

  def parse_html
    return if self.body_html.nil?

    document = Nokogiri::HTML.fragment(self.body_html)

    if document.css('style').any?
      # For now, screw iframes.
      # self.display_in_iframe = true
    end

    if document.css('script').any?
      document.css('script').each(&:remove)
      self.body_html = document.to_html
    end
  end
end
