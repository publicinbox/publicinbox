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
end
