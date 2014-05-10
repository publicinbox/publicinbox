class Extract
  def self.name_from_email_field(email_field)
    return nil if email_field.nil?
    email_field.match(/^(.*) <.*>$/) && $1
  end
end
