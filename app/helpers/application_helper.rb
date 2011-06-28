module ApplicationHelper
  # Return a title on a per-page basis.
  def title
    base_title = "Mapsqueek"
    if @title.nil?
      base_title
    else
      "#{base_title} | #{@title}"
    end
  end
  def logo
    image_tag("mapsqueek_logo.jpg", :alt => "Pip", :class => "round")
  end
  def name
    image_tag("mapsqueek_name.png", :alt => "Mapsqueek", :class => "round")
  end
end
