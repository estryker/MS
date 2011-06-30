class SqueeksController < ApplicationController
  def new
    @squeek = Squeek.new
    @title = "New Squeek"
  end
  def create
    now = DateTime.now.utc
    # I much prefer working with Time objects ... but they don't seem to give the right year and month in the db
    @squeek = Squeek.new(params[:squeek].merge({:time_utc=>now, :expires=>now + params[:duration].to_i / 24.0}))
    if(@squeek.save)
      flash[:success] = "Squeek created"
      redirect_to root_url
    else
      render 'new'
    end
  end
end
