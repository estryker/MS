require 'spec_helper'

describe SqueeksController do
  render_views

  before(:each) do
    @user = Factory(:user)
    test_sign_in(@user)     
  end

  describe "GET 'new'" do
    it "should be successful" do
      get 'new'
      response.should be_success
    end
    it "should have the right title" do
      get 'new'
      response.should have_selector("title",
            :content => "#{@base_title} | New Squeek")
    end
    it "should have the correct user" do
       get 'new'
       @user.name.should  == current_user.name
       @user.email.should == current_user.email
    end
  end
  
end