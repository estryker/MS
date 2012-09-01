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
      test_users = Koala::Facebook::TestUsers.new(:app_id => '107582139349630', :secret => "ca16bbd5834ab7d4b012ec5e84a0d003")
      user_info = test_users.create(true, "offline_access,read_stream,manage_pages,publish_stream")
      login_url = user_info['login_url']
      user = Koala::Facebook::API.new(user_info['access_token'])
      
      auth = OmniAuth.config.mock_auth[:facebook]
      auth[:credentials][:token] = user_info['access_token']

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
