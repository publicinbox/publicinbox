# == Schema Information
#
# Table name: identities
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  provider    :string(255)
#  provider_id :string(255)
#  name        :string(255)
#  real_name   :string(255)
#  email       :string(255)
#

require 'spec_helper'

describe Identity do
  def create_identity(attributes={})
    Identity.create!({
      :provider => 'whoever',
      :provider_id => '12345'
    }.merge(attributes))
  end

  it 'associates an identity with an existing user with the same e-mail address' do
    sam = create_user('sam')

    identity = create_identity(:email => 'sam@publicinbox.net')

    identity.user.should == sam
  end

  it 'associates an identity with an existing user who has ANOTHER identity w/ the same e-mail' do
    first_identity = create_identity({
      :name => 'jim',
      :email => 'jim@example.com'
    })

    second_identity = create_identity({
      :provider => 'some other provider',
      :name => 'jim',
      :email => 'jim@example.com'
    })

    second_identity.user.should == first_identity.user
  end

  it 'does not mistakenly associate different identities with null e-mails' do
    first_identity = create_identity(:name => 'jim')

    second_identity = create_identity({
      :provider => 'some other provider',
      :name => 'jim',
    })

    second_identity.user.should_not == first_identity.user
  end

  it 'creates a new user if none already exists that matches' do
    identity = Identity.create!({
      :provider => 'whoever',
      :provider_id => '12345',
      :name => 'Joe Schmoe'
    })

    identity.user.user_name.should == 'joe.schmoe'
  end

  it "appends a number onto the end of the new user's name if necessary" do
    existing_user = create_user('phil')

    identity = Identity.create!({
      :provider => 'whoever',
      :provider_id => '12345',
      :name => 'phil'
    })

    identity.user.user_name.should =~ /^phil\d+$/
  end
end
