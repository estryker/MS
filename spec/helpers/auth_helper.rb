OmniAuth.config.test_mode = true
#OmniAuth.config.add_mock(:facebook, {  :provider    => "facebook", 
#                                  :uid         => "1234", 
#                                  :user_info   => {   :name       => "Fletch F. Fletch",
#                                                      :nickname   => "fletch",
#                                                      :urls       => {:Facebook => "www.facebook.com/fletch"}},
#                                  :credentials => {   :token => "lk2j3lkjasldkjflk3ljsdf"} })

OmniAuth.config.add_mock(:facebook, {  :provider    => "facebook", 
                           :uid => "1234",  
                           :user_info => {  
                             :name=>"Fletch F. Fletch",  
                               :urls => {:Facebook =>"http://www.facebook.com/fletch", "Website"=>nil},  
                               :nickname=>"Fletch",  
                               :last_name=>"Fletcher",  
                               :first_name=>"Fletch"},  
                           :credentials =>  {:token => 'asdfkjowefnadjfsakfdh' },
                           :extra =>  
                             {:user_hash=>  
                               {:name=>"Fletch F. Fletch",  
                                 :timezone =>-5,  
                                 :gender =>"male",  
                                 :id=>"...",  
                                 :last_name=>"Fletcher",  
                                 :updated_time=>"2010-01-01T12:00:00+0000",  
                                 :verified=>true,  
                                 :locale=>"en_US",  
                                 :link=>"http://www.facebook.com/fletch",  
                                 :email=>"fletch.f.fletch@yahoo.com",  
                                 :first_name=>"Fletch"}},  
                           }  

OmniAuth.config.add_mock(:twitter, {  :provider    => "twitter", 
                                  :uid         => "2345", 
                                  :user_info   => {   :name       => "Fletch F. Fletch",
                                                      :nickname   => "fletch",
                                                      :urls       => {:Twitter => "www.twitter.com/fletch"}},
                                  :credentials => {   :token => "lk2j3lkjasldkjflk3ljsdf"} })
