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

def create_thread(subject, messages)
  time = Time.now - (messages.size * 10).minutes
  last_message = nil

  messages.each_with_index do |message, i|
    attrs = { :created_at => time }

    if last_message
      attrs[:thread_id] = last_message.thread_id
    end

    case i % 2
    when 0
      last_message = incoming(subject, message, attrs)
    when 1
      last_message = outgoing(subject, message, attrs)
    end

    time += 10.minutes
  end

  puts "Created thread '#{subject}'"
end

def incoming(subject, message, attrs={})
  Message.create!({
    :sender_email => 'daniel.tao@gmail.com',
    :recipient => @dan,
    :subject => subject,
    :body => message
  }.merge(attrs))
end

def outgoing(subject, message, attrs={})
  Message.create!({
    :sender => @dan,
    :recipient_email => 'daniel.tao@gmail.com',
    :subject => subject,
    :body => message
  }.merge(attrs))
end

create_thread("Hey Dan!", [
  "How's it going?",
  "It's going well, how about you?",
  "Oh, pretty good, pretty good. Want to get coffee soon?",
  "You know it! How about tomorrow at Philz?",
  "Sounds good, see you then."
])

create_thread("Hey...", [
  "What's up?"
])

create_thread("Busy?", [
  "You doing anything right now?",
  "No, why?",
  "Let's grab lunch!",
  "OK :)"
])
