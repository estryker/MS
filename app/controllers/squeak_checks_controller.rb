class SqueakChecksController < ApplicationController
  def new
    @squeak_check = SqueakCheck.new
    @title = "New SqueakCheck"
    @user = current_user  || anonymous_user
  end

  def create
    user_id = (current_user || anonymous_user).id

    squeak = Squeak.find(params[:squeak_id])
    if squeak.nil?
      respond_to_user("Couldn't find squeak with id #{params[:squeak_id]}",1,index_path)
      return
    end

    checked_from_latitude = params[:checked_from_latitude]
    checked_from_longitude = params[:checked_from_longitude]
    # params should be: squeak_id, and an optional checked_from_latitude, checked_from_longitude
    @squeak_check = SqueakCheck.new(:user_id => user_id,:squeak_id => squeak.id,
                                    :checked_from_latitude => checked_from_latitude,
                                    :checked_from_longitude => checked_from_longitude, :checked=> true)

    # TODO: put 'respond_to_user' in a helper we can all see
    if(@squeak_check.save)
      respond_to_user("Squeak check accepted!",0,current_path)
    else
      err_msg = @squeak_check.errors.map {|attr,msg| "#{attr} - #{msg}"}.join(' ')
      respond_to_user("Couldn't save squeak check #{err_msg}",1,squeak)
    end
  end

  def update
    squeak_check = SqueakCheck.find(params[:id])
    if squeak_check.nil?
      respond_to_user("Couldn't find squeak check with id #{params[:squeak_id]}",1,index_path)
      return
    end
    if params.has_key? :checked
      if params[:checked] == 'true'
        squeak_check.checked = true
        if squeak_check.save
          respond_to_user("Squeak check updated, checked set to true",0,current_path)
        end
      elsif  params[:checked] == 'false'
        squeak_check.checked = false
        if squeak_check.save
          respond_to_user("Squeak check updated, checked set to false",0,current_path)
        end
      end
    end
  end

  def edit
  end

  # Is this useful??
  #def index
  #end

  def show
  end

end
