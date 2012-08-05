MapsqueakProto::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The test environment is used exclusively to run your application's
  # test suite.  You never need to work with it otherwise.  Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs.  Don't rely on the data there!
  config.cache_classes = true

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection    = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr

  OmniAuth.config.test_mode = true
#OmniAuth.config.add_mock(:facebook, {  :provider    => "facebook", 
#                                  :uid         => "1234", 
#                                  :user_info   => {   :name       => "Fletch F. Fletch",
#                                                      :nickname   => "fletch",
#                                                      :urls       => {:Facebook => "www.facebook.com/fletch"}},
#                                  :credentials => {   :token => "lk2j3lkjasldkjflk3ljsdf"} })

  OmniAuth.config.add_mock(:facebook, {  :provider    => "facebook", 
                             :uid => "1234",  
                             :info => {  
                               :name=>"Fletch F. Fletch",  
                               :urls => {:Facebook =>"http://www.facebook.com/fletch", "Website"=>nil},  
                               :nickname=>"Fletch",  
                               :last_name=>"Fletcher",  
                               :first_name=>"Fletch"},  
                             :credentials =>  {:token => 'asdfkjowefnadjfsakfdh' },
                             :extra =>  
                             {:user_hash=>  
                               {:name=>"Fletch F. Fletch",  
                                 :timezone =>-5,  
                                 :gender =>"male",  
                                 :id=>"...",  
                                 :last_name=>"Fletcher",  
                                 :updated_time=>"2010-01-01T12:00:00+0000",  
                                 :verified=>true,  
                                 :locale=>"en_US",  
                                 :link=>"http://www.facebook.com/fletch",  
                                 :email=>"fletch.f.fletch@yahoo.com",  
                                 :first_name=>"Fletch"
                               }
                             }
                           })
                           
  OmniAuth.config.add_mock(:twitter, {  :provider    => "twitter", 
                             :uid         => "2345", 
                             :info   => {   :name       => "Fletch F. Fletch",
                               :nickname   => "fletch",
                               :urls       => {:Twitter => "www.twitter.com/fletch"}},
                             :credentials => {   :token => "lk2j3lkjasldkjflk3ljsdf"} })
  
end
