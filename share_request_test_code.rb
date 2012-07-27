  # debug
    if(false) # root_url.include?('localhost'))
       token = 'AAABh2GszOn4BAHw3dZCJZBSDJTsR117vdDuJmLOUcSdzuKo4qyZBaOtQZB6dvDZC732ZAxkBsvMuWLoVlcvFgzdhSXB8FpPmM6CcvcvAw36gZDZD'
       uid = '1456286987'
       caption = Time.now < squeak.expires ? "Expires in #{time_ago_in_words(squeak.expires)}" : "Expired #{time_ago_in_words(squeak.expires)} ago."
       uri = URI("https://graph.facebook.com/")
       https = Net::HTTP.start(uri.host, uri.port,:use_ssl => true)
       #Net::HTTP.post_form(,"access_token"=>token, "message" => "I just posted to MapSqueak!",
       #                   "link" => "http://mapsqueak.heroku.com/squeaks/#{squeak.id}&caption=#{caption}")
       
       escape = URI.escape("message=I just posted to MapSqueak!&access_token=#{token}&link=http://mapsqueak.heroku.com/squeaks/#{squeak.id}&caption=#{caption}&picture=#{squeak_map_preview(squeak)}")
       response = https.post("/#{uid}/feed",escape)
       puts "attempted to share to fb: #{response.body}"
       
       redirect_to index_path
       return
      
    elsif(root_url.include?('localhost'))
      user = Koala::Facebook::API.new('AAABh2GszOn4BAHw3dZCJZBSDJTsR117vdDuJmLOUcSdzuKo4qyZBaOtQZB6dvDZC732ZAxkBsvMuWLoVlcvFgzdhSXB8FpPmM6CcvcvAw36gZDZD')
      caption = Time.now < squeak.expires ? "Expires in #{time_ago_in_words(squeak.expires)}" : "Expired #{time_ago_in_words(squeak.expires)} ago."
      
      #`curl -F 'access_token=#{auth.token}' -F 'message=I just posted to MapSqueak!' -F 'link=http://mapsqueak.heroku.com/squeaks/#{squeak.id}' -F 'caption=#{caption} https://graph.facebook.com/#{auth.uid}/feed`
      facebook_args = { 
        :description => "MapSqueak. What\'s happening around you, right now?",
        :link => "http://www.mapsqueak.com/squeak.php?id=#{squeak.id}", # :link => "#{root_url}squeaks/#{squeak.id}", # 
        :name => squeak.text,
        :caption => caption
      }

      ret = user.put_wall_post(squeak.text, facebook_args)
      redirect_to index_path
      return
    end


if squeak.nil?
  if(false)
        # debug only for local testing!!!
        debug = Koala::Facebook::API.new("AAABh2GszOn4BAHw3dZCJZBSDJTsR117vdDuJmLOUcSdzuKo4qyZBaOtQZB6dvDZC732ZAxkBsvMuWLoVlcvFgzdhSXB8FpPmM6CcvcvAw36gZDZD")
        debug.put_wall_post('I just posted to MapSqueak!', { :name => squeak.text,
                              :description => "I just posted to MapSqueak!",
                              :link => 'www.istherea.com',# squeak_link,
                              :caption => Time.now < squeak.expires ? "Expires in #{time_ago_in_words(squeak.expires)}" : "Expired #{time_ago_in_words(squeak.expires)} ago.",
                              # :description => "Posted on MapSqueak!" ,
                              :picture => squeak_map_preview(squeak)
                              
                            })
      end
end

def share 
  # ...
  # This should work, but it doesn't anymore. reverting to link
  #if squeak.image.nil?
  #  facebook_args.merge!(:image => "#{root_url}squeaks/image/#{squeak.id}")
  #else  
  #  # **Note that 'picture' is what is documented. Image was found by mistake. 
  #  # facebook_args.merge!(:picture => "#{root_url}/images/mapsqueak_logo.png)")
  #  facebook_args.merge!(:image => "#{root_url}squeaks/map_image/#{squeak.id}")
  #end
  # facebook_args.merge! :picture => "#{root_url}squeaks/map_image/#{squeak.id}.jpg"
  # facebook_args.merge! :picture => "http://mapsqueak.com/images/mapsqueak.png"


         # don't need these in rails:
          # require 'uri'
          # require 'net/http'
          #uri = URI("https://graph.facebook.com/")
          #https = Net::HTTP.start(uri.host, uri.port,:use_ssl => true)
          #Net::HTTP.post_form(,"access_token"=>token, "message" => "I just posted to MapSqueak!",
          #                   "link" => "http://mapsqueak.heroku.com/squeaks/#{squeak.id}&caption=#{caption}")
          
          #escape = URI.escape("message=#{squeak.text}&access_token=#{auth.token}&link=http://www.mapsqueak.com/squeak.php?id=#{squeak.id}&caption=#{caption}")
          #response = https.post("/#{uid}/feed",escape)
          #puts "attempted to share to fb: #{response.body}"
          #puts "Updated facebook: #{ret.inspect}"
          
end


