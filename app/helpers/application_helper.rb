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

  # Messages are just a loose wrapper around XML or JSON blobs used for error messages or success messages when 
  # there are no data types to be returned. 
  class Message
    def initialize(text,code)
      @info = {:text => text, :code => code.to_i}
    end

    def to_xml
      @info.to_xml(:root => 'message')
    end

    def to_json
      @info.to_xml
    end

    def text
      @info[:text]
    end
  end
end
