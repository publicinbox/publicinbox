module HasUniqueToken
  extend ActiveSupport::Concern

  included do
    before_create :generate_unique_token

    def generate_unique_token
      self.unique_token ||= Randy.string(10)

      until self.token_unique?
        self.unique_token = Randy.string(10)
      end
    end

    def token_unique?
      self.class.find_by(:unique_token => self.unique_token).nil?
    end
  end
end
