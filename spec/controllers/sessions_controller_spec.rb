require 'spec_helper'

describe SessionsController do
  # render_views
  require "#{Rails.root}/app/helpers/sessions_helper.rb"
  include SessionsHelper

  # new API:
  describe "POST 'create'" do 

    # TODO test twitter with and without email

    #before(:each) do
    #  @user = Factory(:user)
    #end

    describe "invalid omniauth login" do 
      it "should respond with an error message" do 
        request.env["omniauth.auth"] = nil

        post 'create'
        response.body.should contain("Not authenticated")
      end
    end

    # auths = Authorization.where(:user_id => current_user.id, :provider => provider_name)

    # NOTE: must use strings instead of symbols in OmniAuth mock_auth's second level attributes
    # auths = Authorization.all
    # assert auths.length == 1, "Auths length: #{auths.length}, inspect: #{auths.inspect}  '#{OmniAuth.config.mock_auth[:facebook].inspect}' '#{OmniAuth.config.mock_auth[:facebook][:provider]}' '#{OmniAuth.config.mock_auth[:facebook][:uid]}' "

    describe "first sign in of facebook user" do 
      before(:each) do 
        request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:facebook]
        post 'create'
      end

      it "should create an authorization record" do 
        auths = Authorization.where(:uid => OmniAuth.config.mock_auth[:facebook]['uid'],:provider => OmniAuth.config.mock_auth[:facebook]['provider'])
        assert auths.length == 1, "Auths length: #{auths.length}, inspect: #{auths.inspect}"
      end

      it "should fill in auth token" do 
        auths = Authorization.where(:uid => OmniAuth.config.mock_auth[:facebook]['uid'],:provider => OmniAuth.config.mock_auth[:facebook]['provider'])
        assert auths.first.token != nil
      end
      
      it "should make it signed_in" do 
        assert signed_in?, "Not signed in"
      end

      it "should make it signed_in_to(:facebook)" do 
        assert signed_in_to?(:facebook), "Not signed in to facebook"
      end

      it "should make the authorized user the current_user" do 
        auths = Authorization.where(:uid => OmniAuth.config.mock_auth[:facebook]['uid'],:provider => OmniAuth.config.mock_auth[:facebook]['provider'])
        user = User.find(auths.first.user_id)
        assert user == current_user, "User: #{user.name} (#{user}) != #{current_user.name} (#{current_user})"
      end 
      it "should only have one user after signin" do 
        users = User.all
        assert users.length == 1, "Users length: #{users.length}, '#{users.inspect}' '#{Authorization.all.inspect}'"
      end
    end

    describe "sign out of facebook" do 
      before(:each) do 
        request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:facebook]
        post 'create'
        post 'destroy', :provider => 'facebook'
      end
      it "should set auth token to nil" do 
        auths = Authorization.where(:uid => OmniAuth.config.mock_auth[:facebook]['uid'],:provider => OmniAuth.config.mock_auth[:facebook]['provider'])
        assert auths.first.token.nil?
      end
    end

    describe "sign out of all" do 
      before(:each) do 
        request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:facebook]
        post 'create'
        post 'destroy'
      end
      it "should set auth token to nil" do 
        auths = Authorization.where(:uid => OmniAuth.config.mock_auth[:facebook]['uid'],:provider => OmniAuth.config.mock_auth[:facebook]['provider'])
        assert auths.first.token.nil?
      end
    end

    describe "twitter auth for user already signed in with facebook" do 
      before(:each) do 
        request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:facebook]
        post 'create'
      end

      it "should start with user signed in" do 
        assert signed_in?
      end

      it "should keep user signed in" do 
        request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:twitter]
        post 'create'
        assert signed_in?
      end

      it "should start with one facebook auth, and add a twitter authorization" do 
        auths = Authorization.where(:uid => OmniAuth.config.mock_auth[:facebook]['uid'], :provider => 'facebook')
        assert auths.length == 1, "Facebook auths length after facebook, before twitter: #{auths.length}, inspect: #{auths.inspect}"

        auths = Authorization.all
        assert auths.length == 1, "All auths length after facebook, before twitter: #{auths.length}, inspect: #{auths.inspect}"

        request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:twitter]
        post 'create'

        auths = Authorization.where(:uid => OmniAuth.config.mock_auth[:twitter]['uid'], :provider => 'twitter')
        assert auths.length == 1, "Twitter auths length after twitter signin: #{auths.length}, inspect: #{auths.inspect}"

        auths = Authorization.all
        assert auths.length == 2, "All auths length: #{auths.length}, inspect: #{auths.inspect}"
      end

      it "should fill in auth token of new authorization" do 
        request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:twitter]
        post 'create'

        auths = Authorization.where(:uid => OmniAuth.config.mock_auth[:twitter]['uid'], :provider => 'twitter')
        assert auths.first.token != nil
      end

      it "should only have one user after twitter signin" do 
        request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:twitter]
        post 'create'
        users = User.all
        assert users.length == 1, "Users length: #{users.length}, '#{users.inspect}' '#{Authorization.all.inspect}'"
      end
    end

    describe "multiple signins" do 
       before(:each) do 
        request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:facebook]
        post 'create'
        request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:twitter]
        post 'create'
      end

      it "should only have one user after signin, signout of all and signin" do 
        post 'destroy'
        request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:facebook]
        post 'create'
        request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:twitter]
        post 'create'
        users = User.all
        assert users.length == 1, "Users length: #{users.length}, '#{users.inspect}',  '#{Authorization.all.inspect}'"
      end

      it "should have tokens for all auths" do 
        auths = Authorization.all
        tokenless_auths = auths.find_all {|a| a.token.nil?}
        assert tokenless_auths.empty?, "Tokenless auths: #{tokenless_auths}"
      end
    end
  end

  # Old API:

  #describe "GET 'new'" do
  #  it "should be successful" do
  #    get 'new'
  #    response.should be_success
  #  end
  #  it "should have the right title" do
  #    get :new
  #    response.should have_selector("title", :content => "Sign in")
  #  end
  #end
  #describe "POST 'create'" do

  #  describe "invalid signin" do

  #    before(:each) do
  #      @attr = { :email => "email@example.com", :password => "invalid" }
  #    end
  #
  #    it "should re-render the new page" do
  #      post :create, :session => @attr
  #      response.should render_template('new')
  #    end

   #   it "should have the right title" do
   #     post :create, :session => @attr
   #     response.should have_selector("title", :content => "Sign in")
   #   end

    #  it "should have a flash.now message" do
    #    post :create, :session => @attr
    #    flash.now[:error].should =~ /invalid/i
    #  end
    #end

   #describe "with valid email and password" do

    #  before(:each) do
    #    @user = Factory(:user)
    #    @attr = { :email => @user.email, :password => @user.password }
    #  end

     # it "should sign the user in" do
     #   post :create, :session => @attr
     #   controller.current_user.should == @user
     #   controller.should be_signed_in
     # end

      #it "should redirect to the user show page" do
      #  post :create, :session => @attr
      #  response.should redirect_to(user_path(@user))
      #end
   # end
  #end
  #describe "DELETE 'destroy'" do

   # it "should sign a user out" do
   #   test_sign_in(Factory(:user))
   #   delete :destroy
   #   controller.should_not be_signed_in
   #   response.should redirect_to(index_path)
   # end
  #end
end
