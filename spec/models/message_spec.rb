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
end
