class PagesController < ApplicationController
  def home
    @json = Squeek.all(:conditions => ["expires > ?",DateTime.now.utc]).to_gmaps4rails
  end

  def get
  end

  def gallery
  end

  def news
  end

  def about
  end

  def terms
  end

  def contact
  end

end
