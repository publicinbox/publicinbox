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

      it 'allows underscores' do
        create_user('mike_tyson')
      end

      it 'allows numbers' do
        create_user('superman2000')
      end
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

  describe '#delete_message!' do
    let(:user) { create_user('user') }

    context 'when the user is the sender' do
      it 'simply deletes messages to external recipients' do
        message = create_message(user, :recipient_email => 'joe@gmail.com')
        user.delete_message!(message)
        Message.find_by(:id => message.id).should be_nil
      end

      it '"unlinks" the user from messages to internal recipients' do
        recipient = create_user('recipient')
        message = create_message(user, :recipient => recipient)
        user.delete_message!(message)

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
        user.delete_message!(message)
        Message.find_by(:id => message.id).should be_nil
      end

      it '"unlinks" the user from messages from internal senders' do
        sender = create_user('sender')
        message = create_message(sender, :recipient => user)
        user.delete_message!(message)

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

        sender.delete_message!(message)
        recipient.delete_message!(message)

        Message.find_by(:id => message.id).should be_nil
      end
    end

    context 'when the user is some random schmuck' do
      it "doesn't let him delete the message" do
        sender = create_user('sender')
        message = create_message(sender)
        should_fail { user.delete_message!(message) }
      end
    end
  end
end
