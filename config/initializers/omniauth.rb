Rails.application.config.middleware.use OmniAuth::Builder do
  # Note I couldn't find publish type settings on the facebook developer page
  # old ca16bbd5834ab7d4b012ec5e84a0d003'
  provider :facebook,  '107582139349630', '25da8dc7ba1ee69eba5fc2c316ea6528' , :scope => "publish_stream,publish_checkins" # read_stream

  # Note that you can change an app's permissions on the twitter development page
  provider :twitter, 'K1tkT7Jpi3Ujl0Ftv2V1A', 'UzXlol9ZoDd5uJzuhJpiEFtT0reBcQdTO8XSLVp1k'
  # provider :google, 'domain.com', 'secret', :scope => 'https://mail.google.com/mail/feed/atom/'"
  # provider :google_oauth2, 'mapsqueakomni.heroku.com', :scope => 'https://www.googleapis.com/auth/plus.me'
  provider :istherea, 'Cz5ubYbnrdnvJHmOGnFLg5DENILe20evp4VYyVDq', 'G0GMTjfoXJkJ2sJMHBbM0kdMFxogiNhOV7TAbJcG'
end
