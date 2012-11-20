require 'spec_helper'

describe ShareRequestsController do

  #describe "POST 'create'" do
  #  it "should be successful" do
  #    post 'create'
  #    response.should be_success
  #  end
  #end
  describe "POST create to facebook" do 
    before(:each) do
      @squeak = Factory(:squeak) 
      @user = Factory(:user)
      test_sign_in(@user)   
      
      # need to get an oath token somehow ...
      test_users = Koala::Facebook::TestUsers.new(:app_id => '107582139349630', :secret => '25da8dc7ba1ee69eba5fc2c316ea6528')
      user_info = test_users.create(true, "offline_access,read_stream,manage_pages,publish_stream")
      login_url = user_info['login_url']
      user = Koala::Facebook::API.new(user_info['access_token'])
      
      auth = OmniAuth.config.mock_auth[:facebook]
      puts 'auth: ' + auth.to_s
      # auth: {"provider"=>"facebook", "uid"=>"1234", "info"=>{"name"=>"Fletch F. Fletch", "urls"=>{:Facebook=>"http://www.facebook.com/fletch", "Website"=>nil}, "nickname"=>"Fletch", "last_name"=>"Fletcher", "first_name"=>"Fletch"}, "credentials"=>{"token"=>"asdfkjowefnadjfsakfdh"}, "extra"=>{"user_hash"=>{:name=>"Fletch F. Fletch", :timezone=>-5, :gender=>"male", :id=>"...", :last_name=>"Fletcher", :updated_time=>"2010-01-01T12:00:00+0000", :verified=>true, :locale=>"en_US", :link=>"http://www.facebook.com/fletch", :email=>"fletch.f.fletch@yahoo.com", :first_name=>"Fletch"}}}
      auth['credentials']['token'] = user_info['access_token']

      request.env["omniauth.auth"] = auth
      post 'share_request/create' # how do I post to another controller??

      # Configure Koala for VCR
      Koala.http_service.faraday_middleware = Proc.new do |builder|
        builder.use VCR::Middleware::Faraday do |cassette|
          cassette.name    'facebook'
          cassette.options :record => :new_episodes
        end
        builder.use Koala::MultipartRequest
        builder.request :url_encoded
        builder.adapter Faraday.default_adapter
      end
    end
    it "should be successful" do 
      post 'create', :squeak_id => @squeak.id, :provider => 'facebook'
      response.should be_success, "Response: #{response.body}"
    end
  end
end
