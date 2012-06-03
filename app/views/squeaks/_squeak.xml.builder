xml.squeak do
     xml.id squeak.id 
     xml.latitude squeak.latitude
     xml.longitude squeak.longitude
     xml.duration squeak.duration
     xml.expires squeak.expires.strftime("%Y-%m-%dT%H:%M:%SZ")
     xml.tag! 'created-at', squeak.created_at.strftime("%Y-%m-%dT%H:%M:%SZ")
     xml.text squeak.text
     xml.has_image squeak.image.nil? ? "false" : "true"
end