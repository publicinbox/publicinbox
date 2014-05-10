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
#  sender_name        :string(255)
#  recipient_name     :string(255)
#

require 'spec_helper'

describe Message do
  describe 'automatically populating id & e-mail fields' do
    let(:message_attrs) do
      {
        :subject => 'Hey',
        :body => 'Long time no see'
      }
    end

    it 'populates sender e-mail, if possible' do
      dan = create_user('dan')
      message = dan.outgoing_messages.create!(message_attrs.merge({
        :recipient_email => 'joe@gmail.com'
      }))
      message.sender_email.should == 'dan@publicinbox.net'
    end

    it 'automatically populates recipient_id, if possible' do
      bob = create_user('bob')
      message = Message.create!(message_attrs.merge({
        :sender_email => 'sam@yahoo.com',
        :recipient_email => 'bob@publicinbox.net'
      }))
      message.recipient_id.should == bob.id
    end

    it 'automatically populates recipient_email, if possible' do
      dan = create_user('dan')
      bob = create_user('bob')
      message = dan.outgoing_messages.create!(message_attrs.merge({
        :recipient => bob
      }))
      message.recipient_email.should == 'bob@publicinbox.net'
    end
  end

  describe 'CC list' do
    it 'accepts a comma- and/or space-separated list and formats as comma-separated' do
      lars = create_user('lars')
      message = create_message(lars, {
        :cc_list => 'bob@hotmail.com, kate@gmail.com sarah@yahoo.com,,john@aol.com'
      })
      message.cc_list.should == 'bob@hotmail.com,kate@gmail.com,sarah@yahoo.com,john@aol.com'
    end
  end

  describe 'BCC list' do
    it 'accepts a comma- and/or space-separated list and formats as comma-separated' do
      lars = create_user('lars')
      message = create_message(lars, {
        :bcc_list => 'bob@hotmail.com, kate@gmail.com sarah@yahoo.com,,john@aol.com'
      })
      message.bcc_list.should == 'bob@hotmail.com,kate@gmail.com,sarah@yahoo.com,john@aol.com'
    end
  end

  describe 'generating a unique token for every message' do
    it 'generates a token for all messages' do
      user = create_user('pat')
      message = create_message(user)
      message.unique_token.should_not be_nil
    end

    it 'ensures tokens are unique' do
      user = create_user('pat')

      first_message = create_message(user, :unique_token => 'foo')
      first_message.unique_token.should == 'foo'

      second_message = create_message(user, :unique_token => 'foo')
      second_message.unique_token.should_not be_nil
      second_message.unique_token.should_not == 'foo'
    end
  end

  describe 'grouping messages into threads' do
    before :each do
      @user = create_user('internal')
    end

    let(:message_data) do
      {
        'sender' => 'external@example.com',
        'recipient' => 'internal@publicinbox.net',
        'subject' => 'Subject',
        'body-plain' => 'body',
      }
    end

    def create_from_external(attributes={})
      Message.create_from_external!(message_data.merge(attributes))
    end

    it 'can associate a message w/ its source via source_token' do
      message = create_message(@user)
      response = create_message(@user, :source_token => message.unique_token)
      response.source.should == message
    end

    describe 'a message originating from within the application' do
      it 'automatically sets thread_id to unique_token, if not present' do
        message = create_message(@user)
        message.thread_id.should_not be_nil
        message.thread_id.should == message.unique_token
      end
    end

    describe 'a message coming from an external source (Mailgun)' do
      it 'raises an error if the recipient does not exist' do
        should_fail do
          create_from_external('recipient' => 'doesnotexist@publicinbox.net')
        end
      end

      it 'populates sender_name using the "From" header' do
        message = create_from_external('From' => 'Joe Schmoe <joe.schmoe@example.com>')
        message.sender_name.should == 'Joe Schmoe'
      end

      it 'populates recipient_name using the "To" header' do
        message = create_from_external('To' => 'Joe Schmoe <joe.schmoe@example.com>')
        message.recipient_name.should == 'Joe Schmoe'
      end

      it 'populates external_id using the "Message-Id" header' do
        message = create_from_external('Message-Id' => 'foo')
        message.external_id.should == 'foo'
      end

      it 'populates external_source_id using the "In-Reply-To" header' do
        message = create_from_external('In-Reply-To' => 'bar')
        message.external_source_id.should == 'bar'
      end
    end

    describe 'a relatively long thread' do
      before :each do
        @source_message = create_message(@user, {
          :external_id => 'yada yada'
        })

        @incoming_message = create_from_external({
          'recipient' => @user.email,
          'Message-Id' => 'blah blah',
          'In-Reply-To' => 'yada yada'
        })

        @outgoing_message = create_message(@user, {
          :external_id => 'fiddle faddle',
          :external_source_id => 'blah blah'
        })

        @following_message = create_from_external({
          'recipient' => @user.email,
          'Message-Id' => 'oh brother',
          'In-Reply-To' => 'fiddle faddle'
        })
      end

      it 'is associated w/ the unique_token of the originating message' do
        @source_message.thread_id.should_not be_nil
        @source_message.thread_id.should == @source_message.unique_token
      end

      it 'associates the first response w/ the thread' do
        @incoming_message.thread_id.should == @source_message.thread_id
      end

      it 'associates the follow-up outgoing message w/ the thread' do
        @outgoing_message.thread_id.should == @source_message.thread_id
      end

      it 'associates the response to the response w/ the thread' do
        @following_message.thread_id.should == @source_message.thread_id
      end

      it 'provides access to all messages in a thread via Message#thread' do
        @source_message.thread.should == [
          @source_message,
          @incoming_message,
          @outgoing_message,
          @following_message
        ]
      end

      it 'provides access to all the messages in a thread BEFORE a given message w/ Message#thread_before' do
        @outgoing_message.thread_before.should == [
          @source_message,
          @incoming_message,
          @outgoing_message
        ]
      end

      it 'provides access to all the messages in a thread AFTER a given message w/ Message#thread_after' do
        @outgoing_message.thread_after.should == [
          @outgoing_message,
          @following_message
        ]
      end
    end

    describe 'an internal thread' do
      before :each do
        @other_user = create_user('internal2')

        @source_message = create_message(@user, {
          :unique_token => 'blaaah',
          :recipient => @other_user
        })

        @reply_message = create_message(@other_user, {
          :source_id => @source_message.id,
          :recipient => @user
        })

        @following_message = create_message(@user, {
          :source_id => @reply_message.id,
          :recipient => @other_user
        })
      end

      it 'associates the first response w/ the thread' do
        @reply_message.thread_id.should == @source_message.thread_id
      end

      it 'associates the follow-up message w/ the thread' do
        @following_message.thread_id.should == @source_message.thread_id
      end
    end
  end

  describe 'archiving messages' do
    before :each do
      @user = create_user('ted')
    end

    it "by default, only messages that haven't been archived are loaded" do
      first_message = create_message(@user)
      second_message = create_message(@user)

      first_message.archive!

      @user.messages.should == [second_message]
    end
  end

  describe 'trims surrounding whitespace...' do
    before :each do
      joe = create_user('joe')
      @message = joe.outgoing_messages.create!({
        :recipient_email => 'roy@hotmail.com',
        :subject => " \t\nHello again!\n\t ",
        :body => " \t\n How've you been? \n\t "
      })
    end

    it 'from the subject' do
      @message.subject.should == 'Hello again!'
    end

    it 'from the body' do
      @message.body.should == "How've you been?"
    end
  end

  describe 'validations' do
    context 'recipient_email' do
      before :each do
        @pete = create_user('pete')
      end

      def bad_email(email)
        should_fail do
          create_message(@pete, :recipient_email => email)
        end
      end

      def good_email(email)
        create_message(@pete, :recipient_email => email)
      end

      it 'must look reasonably like an actual e-mail address' do
        bad_email('foo')
        bad_email('foo.com')
        bad_email('foo@bar@baz')
        good_email('foo@example')
        good_email('foo@example.com')
        good_email('foo.bar@baz.example.com')
      end
    end
  end

  context 'displaying messages' do
    describe 'when the message HTML contains <style> elements' do
      before :each do
        kyle = create_user('kyle')

        @message = create_message kyle, :body_html => <<-EOM
          <style>
            h1 { font-family: sans-serif; }
            p { font-weight: 300; }
          </style>

          <h1>Message header</h1>
          <p>Message body</p>
        EOM
      end

      # TODO: Decide whether or not this should happen. (I'm leaning no.)
      xit 'is marked to display in an <iframe>' do
        @message.display_in_iframe?.should == true
      end
    end

    describe 'otherwise' do
      before :each do
        mark = create_user('mark')

        @message = create_message mark, :body_html => <<-EOM
          <h1>Message header</h1>
          <p>Message body</p>
        EOM
      end

      it 'is not marked to display in an iframe' do
        @message.display_in_iframe?.should == false
      end
    end

    it 'strips out any <script> tags' do
      message = create_message create_user('paul'), :body_html => <<-EOM
        <div class="header">Message header</div>
        <script>alert('Hello!');</script>
        <div class="content">Message body</div>
      EOM

      message.body_html.should =~ Regexp.new([
        '',
        '<div class="header">Message header</div>',
        '<div class="content">Message body</div>',
        ''
      ].join('\\s*'))
    end
  end
end
