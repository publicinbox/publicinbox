class Identity < ActiveRecord::Base
  belongs_to :user

  before_create :populate_user_id

  private

  def populate_user_id
    # It's pretty far-fetched, but MAYBE somebody signed up for Twitter w/ a
    # @publicinbox.net account? Yeah, right...
    self.user ||= User.find_by(:email => self.email)

    # More plausible is that somebody might sign in w/ say, Google, then log out
    # and come back later through Facebook or something. (Although I don't even
    # know if Facebook gives you an e-mail address. I guess I'll find out!)
    if self.user.nil?
      self.user = Identity.find_by(:email => self.email).try(:user)
    end

    # As a last resort, we'll just create a new user for this identity.
    if self.user.nil?
      name_base = self.name.downcase.parameterize('.')
      name = name_base

      until User.find_by(:user_name => name).nil?
        suffix = '%05d' % Randy.integer(0..99999)
        name   = "#{name_base}#{suffix}"
      end

      self.user = User.create!(:user_name => name)
    end
  end
end
