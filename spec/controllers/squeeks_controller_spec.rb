require 'spec_helper'

describe SqueeksController do
  render_views

  before(:each) do
    @user = Factory(:user)
    test_sign_in(@user)    
  
    @squeek = Factory(:squeek, :user_email =>@user.email) # :latitude => @lat, :longitude => @long})
    @other_user_squeek = Factory(:squeek, :user_email =>"not#{@user.email}")
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
            :content => "#{@base_title} | New Squeek")
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
        put :update, :id => @other_user_squeek
        response.should redirect_to @user
      end

      it "should flash an error" do
        put :update, :id => @other_user_squeek
        flash[:error].should =~ /No squeek/
      end
    end

    describe "failure due to bad lat squeek" do

      it "should redirect to the 'edit' page" do
        put :update, {:id => @squeek.id, :squeek => @bad_lat_params}
        response.should redirect_to(:action => 'edit')
      end

    end
    describe "failure due to bad long squeek" do

      it "should render the 'edit' page" do
        put :update, {:id => @squeek.id, :squeek => @bad_long_params}
        response.should redirect_to(:action => 'edit')
      end

    end
    describe "success" do

      before(:each) do
        @attr = { :latitude => 51.0, :longitude => -1.0 }
      end

      it "should change the squeek's attributes" do
        put :update, {:id => @squeek, :squeek => @attr}
        @squeek.reload
        @squeek.latitude.should  == @attr[:latitude]
        @squeek.longitude.should == @attr[:longitude]
      end

      it "should redirect to the squeeks show page" do
        put :update, {:id => @squeek, :squeek => @attr}
        response.should redirect_to(:action => 'show')
      end

      it "should have a flash message" do
        put :update, {:id => @squeek, :squeek => @attr}
        flash[:success].should =~ /updated/
      end
    end
  end
  
  describe "POST 'create'" do

    before(:each) do
        @good_params = {:latitude => 54, :longitude=>-1.69, :text =>'test'}
        @good_duration = 8 
        @bad_duration = 9  
    end

    describe "failure due to bad lat squeek" do

      it "should render the 'new' page" do
        post :create, {:duration => @good_duration, :squeek => @bad_lat_params}
        response.should render_template('new')
      end

    end
    describe "failure due to bad long squeek" do

      it "should render the 'new' page" do
        post :create, {:duration => @good_duration, :squeek => @bad_long_params}
        response.should render_template('new')
      end

    end
    describe "failure due to bad duration" do

      it "should render the 'new' page" do
        post :create, {:duration => @bad_duration, :squeek => @good_params}
        response.should render_template('new')
      end

    end
    describe "success" do

      before(:each) do
        
      end
      it "should render the squeeks edit page" do
        post :create, {:duration => @good_duration, :squeek => @good_params}
        response.should render_template('edit')
      end

      it "should have a flash message" do
        post :create, {:duration => @good_duration, :squeek => @good_params}
        flash[:success].should =~ /created/
      end
      it "should return json" do
        post :create, {:duration => @good_duration, :squeek => @good_params}.to_json
        response.should 
      end
    end
  end
end