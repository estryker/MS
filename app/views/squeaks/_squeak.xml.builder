xml.squeak do
     xml.id squeak.id 
     xml.latitude squeak.latitude
     xml.longitude squeak.longitude
     xml.duration squeak.duration
     xml.expires squeak.expires
     xml.tag! 'created-at', squeak.created_at
     xml.text squeak.text
end