require 'spec_helper'

describe SqueeksController do
  render_views

  before(:each) do
    
  end

  describe "GET 'mobile_app'" do
    it "should be successful" do
      get 'mobile_app'
      response.should be_success
    end
    it "should have the right title" do
      get 'mobile_app'
      response.should have_selector("title",
            :content => "#{@base_title} | Mobile App")
    end
  end
  
end