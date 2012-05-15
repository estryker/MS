module ApplicationHelper
  # Return a title on a per-page basis.
  def title
    base_title = "Mapsqueak"
    if @title.nil?
      base_title
    else
      "#{base_title} | #{@title}"
    end
  end
  def logo
    image_tag("mapsqueak_logo.png", :alt => "Pip", :class => "round")
  end
 
  def name
    image_tag("mapsqueak_name.png", :alt => "Mapsqueak", :class => "round")
  end

  # use the file system to store a google static image
  # TODO: if this works, add it to the squeak model
  def squeak_map_preview(squeak)
    # Note that downloading doesn't work on heroku
    # download_path = "public/images/map_#{squeak.id}.png"
    # picture_url = "http://maps.googleapis.com/maps/api/staticmap?center=#{squeak.latitude},#{squeak.longitude}&zoom=13&size=200x200&maptype=roadmap&markers=color:blue%7Clabel:M%7C#{squeak.latitude},#{squeak.longitude}&sensor=true"

    # Note that the pwd is the dir that
    # puts `pwd`
    # puts "#{download_path}"
    #puts "#{picture_url}"
    #unless File.exist? download_path
    #  puts "calling: wget #{picture_url} -O #{download_path}"
    #  puts `wget \"#{picture_url}\" -O #{download_path}`
    #end
    # when the path starts with /images, then the rails app knows to look in public/images
    # return download_path.sub("public","")

    # "http://maps.googleapis.com/maps/api/staticmap?center=#{squeak.latitude},#{squeak.longitude}&zoom=13&size=200x200&maptype=roadmap&markers=color:blue%7Clabel:M%7C#{squeak.latitude},#{squeak.longitude}&sensor=true"
    "http://bit.ly/J6SZXR"
  end
end
