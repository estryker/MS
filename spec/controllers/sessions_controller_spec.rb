require 'spec_helper'

describe SessionsController do
  # render_views
  require "#{Rails.root}/app/helpers/sessions_helper.rb"
  include SessionsHelper

  # new API:
  describe "POST 'create'" do 

    # TODO test twitter with and without email

    before(:each) do
      @user = Factory(:user)

    end

    describe "invalid omniauth login" do 
      it "should respond with an error message" do 
        request.env["omniauth.auth"] = nil

        post 'create'
        response.body.should contain("Not authenticated")
      end
    end

    # auths = Authorization.where(:user_id => current_user.id, :provider => provider_name)

    describe "new valid auth for already signed in user" do 
      before(:each) do 
        sign_in @user
      end
      it "should keep user signed in" do 
        request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:facebook]
        post 'create'
        assert signed_in?
      end

      it "should have only one authorization and with filled in token" do 
        request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:facebook]
        post 'create'
        auths = Authorization.where(:user_id => current_user.id, :provider => 'facebook')
        assert auths.length == 1, "Auths length: #{auths.length}, inspect: #{auths.inspect}"
        auths.first.should_not_equal nil
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
