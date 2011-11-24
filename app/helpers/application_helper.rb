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
    image_tag("mapsqueak_logo.jpg", :alt => "Pip", :class => "round")
  end
  def name
    image_tag("mapsqueak_name.png", :alt => "Mapsqueak", :class => "round")
  end
end
