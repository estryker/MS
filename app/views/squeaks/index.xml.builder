xml.squeaks do
  # ** warning. need to figure out how to pass 'squeak' to the partial for code reuse!
  # HOWEVER - this does allow my index to render the squeak differently than each
  #           squeak individually
  #@squeaks.each do | squeak | 
  #   xml << render(:partial => 'squeaks/squeak')
  #end
  @squeaks.each do | squeak | 
     xml.squeak do
     xml.id  squeak.id 
     xml.latitude  squeak.latitude
     xml.longitude  squeak.longitude
     xml.duration squeak.duration
     xml.expires squeak.expires
     xml.tag! 'created-at',  squeak.created_at
     xml.text squeak.text
   end
  end
end