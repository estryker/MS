Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook,  '107582139349630', 'ca16bbd5834ab7d4b012ec5e84a0d003', :scope => "publish_stream"
  provider :twitter, 'K1tkT7Jpi3Ujl0Ftv2V1A', 'UzXlol9ZoDd5uJzuhJpiEFtT0reBcQdTO8XSLVp1k'
  # provider :google, 'domain.com', 'secret', :scope => 'https://mail.google.com/mail/feed/atom/'"
  # provider :google_oauth2, 'mapsqueakomni.heroku.com', :scope => 'https://www.googleapis.com/auth/plus.me'
end