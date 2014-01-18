Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2,
    Rails.application.secrets.google_client_id,
    Rails.application.secrets.google_client_secret

  provider :facebook,
    Rails.application.secrets.facebook_app_id,
    Rails.application.secrets.facebook_secret

  provider :twitter,
    Rails.application.secrets.twitter_key,
    Rails.application.secrets.twitter_secret
end
