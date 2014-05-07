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

def create_thread(subject_lines)
  time = Time.now - (subject_lines.size * 10).minutes

  subject_lines.each_with_index do |subject, i|
    case i % 2
    when 0
      incoming(subject, :created_at => time)
    when 1
      outgoing(subject, :created_at => time)
    end

    time += 10.minutes
  end
end

def incoming(message, attrs={})
  Message.create!({
    :thread_id => 'foo',
    :sender_email => 'daniel.tao@gmail.com',
    :recipient => @dan,
    :subject => 'Hey Dan!',
    :body => message,
  }.merge(attrs))
end

def outgoing(message, attrs={})
  Message.create!({
    :thread_id => 'foo',
    :sender => @dan,
    :recipient_email => 'daniel.tao@gmail.com',
    :subject => 'Hey Dan!',
    :body => message
  }.merge(attrs))
end

create_thread([
  "How's it going?",
  "It's going well, how about you?",
  "Oh, pretty good, pretty good. Want to get coffee soon?",
  "You know it! How about tomorrow at Philz?",
  "Sounds good, see you then."
])
