require 'spec_helper'
require 'xmlsimple'

describe SqueaksController do
  render_views

  before(:each) do
    @user = Factory(:user)
    #test_sign_in(@user)    
  
    #@squeak = Factory(:squeak, :user_email =>@user.email) # :latitude => @lat, :longitude => @long})
    @squeak = Factory(:squeak) # :latitude => @lat, :longitude => @long})
    # @other_user_squeak = Factory(:squeak, :user_email =>"not#{@user.email}")
    # need to test the edge cases better than this
    @bad_lat_params = {:latitude=>90.1}
    @bad_long_params = {:longitude=>180.1}
  end

  describe "GET map preview" do 
    it "should be redirected to mapquestapi" do 
      get :map_preview, {:id => @squeak.id }
      response.should be_redirect, "body: #{response.body}"
      assert response.body =~ /mapquestapi/i, "body: #{response.body}"
    end
  end

  describe "POST XML to create squeak" do 
    before (:each) do 
      @squeak_xml = %Q(<squeak>
      <latitude>39.191021</latitude>
      <longitude>-76.81881</longitude>
      <duration>2.0</duration>
      <text>Squeak text here</text>
      <timezone>EDT</timezone>
     </squeak>)
      @squeak_hash = XmlSimple.xml_in(@squeak_xml,:keeproot => false, :ForceArray => false).merge({:salt => "7aX5BVV1dGk=", :hash=>"lWC7UXOZ3AFK2kwt6Y2tHQ=="})
    end

    it "should accept XML with all necessary fields" do 
      post :create, {:format => 'xml', :squeak => @squeak_hash}
      response.should be_success, @squeak_hash.to_s
    end

    it "should complain when no latitude is given" do 
      @squeak_hash.delete('latitude')
      post :create, {:format => 'xml', :squeak => @squeak_hash}
      assert response.body.match(/Couldn't create squeak/), "response: #{response.body}"
    end

    it "should complain when no longitude is given" do 
      @squeak_hash.delete('longitude')
      post :create, {:format => 'xml', :squeak => @squeak_hash}
      assert response.body.match(/Couldn't create squeak/), "response: #{response.body}"
    end
    it "should complain when a latitude < -90 is given" do 
      @squeak_hash['latitude'] = -90.1
      post :create, {:format => 'xml', :squeak => @squeak_hash}
      assert response.body.match(/Couldn't create squeak/), "response: #{response.body}"
    end
    it "should complain when a latitude > 90 is given" do 
      @squeak_hash['latitude'] = 90.01
      post :create, {:format => 'xml', :squeak => @squeak_hash}
      assert response.body.match(/Couldn't create squeak/), "response: #{response.body}"
    end
    it "should complain when a longitude < -180 is given" do 
      @squeak_hash['longitude'] = -180.01
      post :create, {:format => 'xml', :squeak => @squeak_hash}
      assert response.body.match(/Couldn't create squeak/), "response: #{response.body}"
    end
    it "should complain when a longitude > 180 is given" do 
      @squeak_hash['longitude'] = 180.01
      post :create, {:format => 'xml', :squeak => @squeak_hash}
      assert response.body.match(/Couldn't create squeak/), "response: #{response.body}"
    end
    it "should complain when a duration < 0 is given" do 
      @squeak_hash['duration'] = -1
      post :create, {:format => 'xml', :squeak => @squeak_hash}
      assert response.body.match(/Couldn't create squeak/), "response: #{response.body}"
    end
    it "should complain when a duration == 0 is given" do 
      @squeak_hash['duration'] = 0
      post :create, {:format => 'xml', :squeak => @squeak_hash}
      assert response.body.match(/Couldn't create squeak/), "response: #{response.body}"
    end
    it "should complain when a duration > 24 hours is given" do 
      @squeak_hash['duration'] = 24.01
      post :create, {:format => 'xml', :squeak => @squeak_hash}
      assert response.body.match(/Couldn't create squeak/), "response: #{response.body}"
    end
    it "should silently truncate to 140 characters" do 
      @squeak_hash['text'] = "X" * 141
      post :create, {:format => 'xml', :squeak => @squeak_hash}
      assert response.body.match(/Couldn't create squeak/), "response: #{response.body}"
    end
    it "should not allow missing HMAC" do 
      @squeak_hash.delete(:salt)
      @squeak_hash.delete(:hash)
      post :create, {:format => 'xml', :squeak => @squeak_hash}
      assert response.body.match(/Couldn't create squeak: No HMAC received/), "response: #{response.body}"
    end    
    it "should not allow incorrect HMAC" do 
      @squeak_hash[:hash] = "wrong"
      post :create, {:format => 'xml', :squeak => @squeak_hash}
      assert response.body.match(/Couldn't create squeak: Incorrect HMAC/), "response: #{response.body}"
    end
  end

  describe "GET XML by id" do 
    # create one squeak with an image, 
    # one squeak without an image
 
=begin 
    example returned XML: 
     <squeak>
      <id>637</id>
      <latitude>39.191021</latitude>
      <longitude>-76.81881</longitude>
      <duration>2.0</duration>
      <expires>2012-06-10T01:14:28Z</expires>
      <created-at>2012-06-09T23:14:28Z</created-at>
      <text>Boys night out. Seats available at pub dog.</text>
      <timezone/>
      <has_image>true</has_image>
     </squeak>
=end

    before(:each) do 
      @squeak = Factory(:squeak) 
      get :show, {:format => 'xml', :id => @squeak.id}
      @xml = XmlSimple.xml_in(response.body,:keeproot => true, :ForceArray => false)     
      @squeak2 = Factory(:squeak)    
      get :show, {:format => 'xml', :id => @squeak2.id}
      @xml2 = XmlSimple.xml_in(response.body,:keeproot => true, :ForceArray => false)
    end
    it "should have squeak as the root element" do 
      assert @xml.has_key?('squeak'), "response: #{@xml.to_s}"
    end
    it "should have an id" do 
      assert @xml['squeak'].has_key?('id'), "response: #{@xml.to_s}"
    end
    it "should have latitude" do 
      assert @xml['squeak'].has_key?('latitude'), "response: #{@xml.to_s}"    
    end
    it "should have longitude" do 
      assert @xml['squeak'].has_key?('longitude'), "response: #{@xml.to_s}"    
    end
    it "should have duration" do 
      assert @xml['squeak'].has_key?('duration'), "response: #{@xml.to_s}"    
    end
    it "should have expires" do 
      assert @xml['squeak'].has_key?('expires'), "response: #{@xml.to_s}"    
    end
    it "should have text" do 
      assert @xml['squeak'].has_key?('text'), "response: #{@xml.to_s}"    
    end
    it "should have timezone" do 
      assert @xml['squeak'].has_key?('timezone'), "response: #{@xml.to_s}"    
    end
    it "should have has_image" do 
      assert @xml['squeak'].has_key?('has_image'), "response: #{@xml.to_s}"
    end

   # describe "squeak with image" do 

    it "should have has_image set to true" do 
      assert @xml['squeak']['has_image'] == 'true', "xml #{@xml.to_s}"
    end
    it "hex escaped input should have a binary image" do 
      get :squeak_image, {:id => @squeak.id, :format => 'jpg'}
      assert response != nil
      assert response.body == "\xFF\xFF", "img: #{@squeak.image.each_byte.map {|b| '%02X' % b}.join('')} body: \'#{response.body.each_byte.map {|b| '%02X' % b}.join('')}\'"
    end     
    it "binary input should have a binary image" do 
      get :squeak_image, {:id => @squeak2.id, :format => 'jpg'}
      assert response.body != nil
      assert response.body == "\xFF\xFF", "img: #{@squeak2.image.each_byte.map {|b| '%02X' % b}.join('')} body: \'#{response.body.each_byte.map {|b| '%02X' % b}.join('')}\'"
    end
    # end
  end
  
  #describe "GET 'new'" do
  #  it "should be successful" do
  #    get 'new'
  #    response.should be_success
  #  end
  #  it "should have the right title" do
  #    get 'new'
  #    response.should have_selector("title",
  #          :content => "#{@base_title} | New Squeak")
  #  end
  #  it "should have the correct user" do
  #     get 'new'
  #     @user.name.should  == controller.current_user.name
  #     @user.email.should == controller.current_user.email
  #  end
  #end
  describe "PUT 'update'" do

    before(:each) do
 
    end

#    describe "failure due to wrong user" do

 #     it "should redirect to the 'edit' page" do
 #       put :update, :id => @other_user_squeak
 #       response.should redirect_to @user
 #     end

  #    it "should flash an error" do
  #      put :update, :id => @other_user_squeak
  #      flash[:error].should =~ /No squeak/
  #    end
  #  end

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

    #describe "failure due to bad lat squeak" do

    #  it "should render the 'new' page" do
    #    #raise "#{@good_params.merge(@bad_lat_params).merge(@good_duration)}"
    #    post :create, {:squeak => @good_params.merge(@bad_lat_params)}
    #    response.should render_template('new')
    #  end

    #end
    #describe "failure due to bad long squeak" do

    #  it "should render the 'new' page" do
    #    post :create, {:squeak => @good_params.merge(@bad_long_params)}
    #    response.should render_template('new')
    #  end

    #end
    #describe "failure due to bad duration" do

    #  it "should render the 'new' page" do
    #    post :create, {:squeak => @good_params.merge(@bad_duration)}
    #    response.should render_template('new')
    #  end

    #end
    describe "success" do

      before(:each) do
        
      end
      #it "should render the squeaks edit page" do
      #  post :create, {:squeak => @good_params}
      #  response.should render_template('edit')
      #end

      #it "should have a flash message" do
      #  post :create, {:squeak => @good_params}
      #  flash[:success].should =~ /created/
      #end
      it "should accept a json request" do
        post :create, {:squeak => @good_params},:content_type => 'application/json'
        response.should be_success
      end    
      it "should accept an xml request" do
        post :create, {:squeak => @good_params},:content_type => 'application/xml'
        response.should be_success
      end
      it "responds to a json request with a json response" do
        post(:create, {:format => 'json', :squeak => @good_params},:content_type => 'application/json')
        parsed_body = JSON.parse(response.body)
        parsed_body[:squeak][:latitude].should == @good_params[:latitude]
        parsed_body[:squeak][:longitude].should == @good_params[:longitude]        
        parsed_body[:squeak][:text].should == @good_params[:text]                
      end
    end
  end
end

__END__


