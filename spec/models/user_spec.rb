require 'spec_helper'

describe User do
  describe 'automatically populating e-mail field' do
    it "sets a user's e-mail to [name]@publicinbox.net" do
      phil = create_user('phil')
      phil.email.should == 'phil@publicinbox.net'
    end

    it "doesn't care if the e-mail field was explicitly set to something else" do
      fred = create_user('fred', :email => 'bigbadfreddy@gmail.com')
      fred.email.should == 'fred@publicinbox.net'
    end
  end
end
