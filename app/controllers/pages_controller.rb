class PagesController < ApplicationController

  def mobile_app
    @title = "Mobile App"
  end

  def news
    @title = "News"
  end
  
  def terms
    @title = "Terms"
  end
  
  def contact
    @title = "Contact"
  end

end
