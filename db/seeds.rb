# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

@dan = User.find_by(:user_name => 'dan') || User.create!({
  :user_name => 'dan',
  :real_name => 'Dan Tao',
  :password => 'passw0rd',
  :password_confirmation => 'passw0rd'
})

Dir.glob(File.join(__dir__, 'seed', '*.json')).each do |file|
  data = JSON.parse(File.read(file))
  Message.create_from_external!(data)
end

# Create back-and-forth thread between me and myself

def incoming(message)
  Message.create!({
    :thread_id => 'foo',
    :sender_email => 'daniel.tao@gmail.com',
    :recipient => @dan,
    :subject => 'Hey Dan!',
    :body => message
  })
end

def outgoing(message)
  Message.create!({
    :thread_id => 'foo',
    :sender => @dan,
    :recipient_email => 'daniel.tao@gmail.com',
    :subject => 'Hey Dan!',
    :body => message
  })
end

incoming("How's it going?")
outgoing("It's going well, how about you?")
incoming("Oh, pretty good, pretty good. Want to get coffee soon?")
outgoing("You know it! How about tomorrow at Philz?")
incoming("Sounds good, see you then.")
