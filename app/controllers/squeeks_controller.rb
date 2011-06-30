class SqueeksController < ApplicationController
  def new
    @squeek = Squeek.new
    @title = "New Squeek"
  end
  def create
    @squeek = Squeek.new(params[:squeek].merge({:time_utc=>Time.now.utc, :expires=>Time.now.utc + params[:duration].to_i.hours}))
    if(@squeek.save)
      flash[:success] = "Squeek created"
      redirect_to root_url
    else
      render 'new'
    end
  end
end
