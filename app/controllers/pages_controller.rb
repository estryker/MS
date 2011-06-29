class PagesController < ApplicationController
  def home
    now = Time.now
    @json = Squeek.all(:conditions => ["expires <= ?",Time.now]).to_gmaps4rails
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
