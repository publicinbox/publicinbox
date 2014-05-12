# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#

def ensure_user(user_name, attributes={})
  user = User.find_by(:user_name => user_name)
  return user if user
  User.create!(attributes.merge(:user_name => user_name))
end

ensure_user('share', {
  :real_name => 'PublicInbox',
  :automated => true
})

require File.join(__dir__, 'seeds.dev') if Rails.env.development?
