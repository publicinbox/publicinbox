# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  user_name       :string(255)
#  email           :string(255)
#  real_name       :string(255)
#  bio             :text
#  external_email  :string(255)
#  password_digest :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  automated       :boolean
#

require 'spec_helper'

describe User do
  describe 'automatically populating fields' do
    it "sets a user's e-mail to [name]@publicinbox.net" do
      phil = create_user('phil')
      phil.email.should == 'phil@publicinbox.net'
    end

    it "doesn't care if the e-mail field was explicitly set to something else" do
      fred = create_user('fred', :email => 'bigbadfreddy@gmail.com')
      fred.email.should == 'fred@publicinbox.net'
    end
  end

  describe 'trims surrounding whitespace...' do
    it 'from user names' do
      create_user(" \t\ndan\n\t ").user_name.should == 'dan'
    end

    it 'from real names' do
      create_user('dan', :real_name => " \t\nDaniel Tao\n\t ").real_name.should == 'Daniel Tao'
    end
  end

  describe 'validations' do
    context 'user_name' do
      it 'disallows special characters' do
        should_fail { create_user('mike*!@') }
      end

      it 'disallows capital letters' do
        should_fail { create_user('MIKE') }
      end

      it 'allows numbers' do
        create_user('superman2000')
      end

      it 'allows underscores' do
        create_user('mike_tyson')
      end

      it 'allows dashes' do
        create_user('peter-pan')
      end

      it 'allows the plus sign' do
        create_user('alexander+the+great')
      end

      it 'allows periods' do
        create_user('john.smith')
      end
    end
  end

  describe '#messages' do
    let(:user) { create_user('user') }

    it 'includes both outgoing and incoming messages' do
      outgoing = create_message(user)
      incoming = create_message(create_user('sender'), :recipient => user)
      user.messages.should =~ [outgoing, incoming]
    end
  end

  describe '#contacts' do
    let(:user) {
      user = create_user('user')
      create_message(user, :recipient_email => 'pete@gmail.com')
      create_message(user, :recipient_email => 'tom@yahoo.com')

      create_message(nil, :sender_email => 'matt@hotmail.com', :recipient => user)
      create_message(nil, :sender_email => 'barb@aol.com', :recipient => user)

      user
    }

    it 'includes the e-mail addresses of people the user has written to' do
      user.contacts.should include('pete@gmail.com', 'tom@yahoo.com')
    end

    it 'includes the e-mail addresses of people who have written to the user' do
      user.contacts.should include('matt@hotmail.com', 'barb@aol.com')
    end

    it 'does not include duplicates' do
      jack = create_user('jack')
      create_message(jack, :recipient_email => 'jill@example.com')
      create_message(jack, :recipient_email => 'jill@example.com')
      jack.contacts.should == ['jill@example.com']
    end
  end

  describe '#create_message!' do
    let(:user) { create_user('user') }

    it 'sets the current user as the sender' do
      message = user.create_message!(:recipient_email => 'recipient@example.com')
      message.sender.should == user
    end

    it 'prevents users from sending messages with no recipients' do
      should_fail { user.create_message!(:subject => 'hello') }
    end

    it 'lets messages through as long as a recipient is set' do
      recipient = create_user('recipient')
      user.create_message!(:recipient => recipient)
      user.create_message!(:recipient_email => 'recipient@example.com')
    end

    it 'populates recipient_id if possible, same as Message#create' do
      recipient = create_user('recipient')
      message = user.create_message!(:recipient_email => 'recipient@publicinbox.net')
      message.recipient.should == recipient
    end

    it 'populates recipient_email if possible, same as Message#create' do
      recipient = create_user('recipient')
      message = user.create_message!(:recipient => recipient)
      message.recipient_email.should == 'recipient@publicinbox.net'
    end
  end

  describe '#archive_message!' do
    let(:user) { create_user('user') }

    context 'when the user is the sender' do
      it 'simply deletes messages to external recipients' do
        message = create_message(user, :recipient_email => 'joe@gmail.com')
        user.archive_message!(message)
        Message.find_by(:id => message.id).should be_nil
      end

      it '"unlinks" the user from messages to internal recipients' do
        recipient = create_user('recipient')
        message = create_message(user, :recipient => recipient)
        user.archive_message!(message)

        # The record should still exist...
        Message.find_by(:id => message.id).should == message

        # It just shouldn't have sender_id anymore
        message.reload.sender_id.should be_nil
      end
    end

    context 'when the user is the recipient' do
      it 'simply deletes messages from external senders' do
        message = Message.create!({
          :sender_email => 'sender@example.com',
          :recipient => user,
          :subject => 'Heyo',
          :body => "How you doin'?"
        })
        user.archive_message!(message)
        Message.find_by(:id => message.id).should be_nil
      end

      it '"unlinks" the user from messages from internal senders' do
        sender = create_user('sender')
        message = create_message(sender, :recipient => user)
        user.archive_message!(message)

        # Record should still exist
        Message.find_by(:id => message.id).should == message

        # Shouldn't have recipient_id
        message.reload.recipient_id.should be_nil
      end
    end

    context 'when both parties delete a message' do
      it 'gone baby gone' do
        sender = create_user('sender')
        recipient = create_user('recipient')

        message = create_message(sender, :recipient => recipient)

        sender.archive_message!(message)
        recipient.archive_message!(message)

        Message.find_by(:id => message.id).should be_nil
      end
    end

    context 'when the user is some random schmuck' do
      it "doesn't let him delete the message" do
        sender = create_user('sender')
        message = create_message(sender)
        should_fail { user.archive_message!(message) }
      end
    end
  end
end
