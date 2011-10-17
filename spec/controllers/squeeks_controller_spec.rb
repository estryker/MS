require 'spec_helper'

describe SqueeksController do
  render_views

  before(:each) do
    @user = Factory(:user)
    test_sign_in(@user)    
    @squeek = Factory(:squeek, :user_email =>@user.email)
    @other_user_squeek = Factory(:squeek, :user_email =>"not#{@user.email}")
    # need to test the edge cases better than this
    #@bad_lat_squeek = Factory(:squeek, :latitude => 90.1)
    #@bad_long_squeek = Factory(:squeek, :longitude => 180.1)
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

      it "should render the 'edit' page" do
        put :update, :id => @other_user_squeek
        response.should render_template('edit')
      end

      it "should flash an error" do
        put :update, :id => @other_user_squeek
        flash[:error].should =~ /No squeek/
      end
    end

    describe "failure due to bad lat squeek" do

      it "should render the 'edit' page" do
        put :update, :id => @obad_lat_squeek
        response.should render_template('edit')
      end

      it "should flash an error" do
        put :update, :id => @other_user_squeek
        flash[:error].should =~ /Invalid/
      end
    end
    describe "failure due to bad long squeek" do

      it "should render the 'edit' page" do
        put :update, :id => @obad_long_squeek
        response.should render_template('edit')
      end

      it "should flash an error" do
        put :update, :id => @bad_long_squeek
        flash[:error].should =~ /Invalid/
      end
    end
    describe "success" do

      before(:each) do
        @attr = { :latitude => 51.0, :longitude => -1.0 }
      end

      it "should change the squeek's attributes" do
        put :update, :id => @squeek
        @squeek.reload
        @squeek.latitude.should  == @attr[:latitude]
        @squeek.longitude.should == @attr[:longitude]
      end

      it "should redirect to the squeeks show page" do
        put :update, :id => @squeek
        response.should redirect_to(squeek_path(@squeek))
      end

      it "should have a flash message" do
        put :update, :id => @squeek
        flash[:success].should =~ /updated/
      end
    end
  end
  
  describe "POST 'create'" do

    before(:each) do
 
    end

    describe "failure due to bad lat squeek" do

      it "should render the 'edit' page" do
        post :create, :id => @obad_lat_squeek
        response.should render_template('edit')
      end

      it "should have the right title" do
        post :create, :id => @other_user_squeek
        response.should have_selector("title", :content => "Edit Squeek")
      end
      it "should flash an error" do
        post :create, :id => @other_user_squeek
        flash[:error].should =~ /Invalid/
      end
    end
    describe "failure due to bad long squeek" do

      it "should render the 'edit' page" do
        post :create, :id => @obad_long_squeek
        response.should render_template('edit')
      end

      it "should have the right title" do
        post :create, :id => @bad_long_squeek
        response.should have_selector("title", :content => "Edit Squeek")
      end
      it "should flash an error" do
        post :create, :id => @bad_long_squeek
        flash[:error].should =~ /Invalid/
      end
    end
    describe "success" do

      before(:each) do
        @attr = { :latitude => 51.0, :longitude => -1.0 }
      end

      it "should create the squeek's attributes" do
        post :create, :id => @squeek
        @squeek.reload
        @squeek.latitude.should  == @attr[:latitude]
        @squeek.longitude.should == @attr[:longitude]
      end

      it "should redirect to the squeeks show page" do
        post :create, :id => @squeek
        response.should redirect_to(squeek_path(@squeek))
      end

      it "should have a flash message" do
        post :create, :id => @squeek
        flash[:success].should =~ /created/
      end
    end
  end
  
  
end