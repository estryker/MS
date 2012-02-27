require 'spec_helper'

describe SqueaksController do
  render_views

  before(:each) do
    @user = Factory(:user)
    test_sign_in(@user)    
  
    @squeak = Factory(:squeak, :user_email =>@user.email) # :latitude => @lat, :longitude => @long})
    @other_user_squeak = Factory(:squeak, :user_email =>"not#{@user.email}")
    # need to test the edge cases better than this
    @bad_lat_params = {:latitude=>90.1}
    @bad_long_params = {:longitude=>180.1}
  end

  describe "GET 'new'" do
    it "should be successful" do
      get 'new'
      response.should be_success
    end
    it "should have the right title" do
      get 'new'
      response.should have_selector("title",
            :content => "#{@base_title} | New Squeak")
    end
    it "should have the correct user" do
       get 'new'
       @user.name.should  == controller.current_user.name
       @user.email.should == controller.current_user.email
    end
  end
  describe "PUT 'update'" do

    before(:each) do
 
    end

    describe "failure due to wrong user" do

      it "should redirect to the 'edit' page" do
        put :update, :id => @other_user_squeak
        response.should redirect_to @user
      end

      it "should flash an error" do
        put :update, :id => @other_user_squeak
        flash[:error].should =~ /No squeak/
      end
    end

    describe "failure due to bad lat squeak" do

      it "should redirect to the 'edit' page" do
        put :update, {:id => @squeak.id, :squeak => @bad_lat_params}
        response.should redirect_to(:action => 'edit')
      end

    end
    describe "failure due to bad long squeak" do

      it "should render the 'edit' page" do
        put :update, {:id => @squeak.id, :squeak => @bad_long_params}
        response.should redirect_to(:action => 'edit')
      end

    end
    describe "success" do

      before(:each) do
        @attr = { :latitude => 51.0, :longitude => -1.0 }
      end

      it "should change the squeak's attributes" do
        put :update, {:id => @squeak, :squeak => @attr}
        @squeak.reload
        @squeak.latitude.should  == @attr[:latitude]
        @squeak.longitude.should == @attr[:longitude]
      end

      it "should redirect to the squeaks show page" do
        put :update, {:id => @squeak, :squeak => @attr}
        response.should redirect_to(:action => 'show')
      end

      it "should have a flash message" do
        put :update, {:id => @squeak, :squeak => @attr}
        flash[:success].should =~ /updated/
      end
    end
  end
  
  describe "POST 'create'" do

    before(:each) do
        @good_params = {:latitude => 54, :longitude=>-1.69, :text =>'test', :duration => 8}
        @bad_duration = {:duration => 9}  
    end

    describe "failure due to bad lat squeak" do

      it "should render the 'new' page" do
        #raise "#{@good_params.merge(@bad_lat_params).merge(@good_duration)}"
        post :create, {:squeak => @good_params.merge(@bad_lat_params)}
        response.should render_template('new')
      end

    end
    describe "failure due to bad long squeak" do

      it "should render the 'new' page" do
        post :create, {:squeak => @good_params.merge(@bad_long_params)}
        response.should render_template('new')
      end

    end
    describe "failure due to bad duration" do

      it "should render the 'new' page" do
        post :create, {:squeak => @good_params.merge(@bad_duration)}
        response.should render_template('new')
      end

    end
    describe "success" do

      before(:each) do
        
      end
      it "should render the squeaks edit page" do
        post :create, {:squeak => @good_params}
        response.should render_template('edit')
      end

      it "should have a flash message" do
        post :create, {:squeak => @good_params}
        flash[:success].should =~ /created/
      end
      it "should accept a json request" do
        post :create, {:squeak => @good_params},:content_type => 'application/json'
        response.should be_success
      end    
      it "should accept an xml request" do
        post :create, {:squeak => @good_params},:content_type => 'application/xml'
        response.should be_success
      end
      it "responds to a json request with a json response" do
        post(:create, {:squeak => @good_params},:content_type => 'application/json')
        parsed_body = JSON.parse(response.body)
        parsed_body[:squeak][:latitude].should == @good_params[:latitude]
        parsed_body[:squeak][:longitude].should == @good_params[:longitude]        
        parsed_body[:squeak][:text].should == @good_params[:text]                
      end
    end
  end
end