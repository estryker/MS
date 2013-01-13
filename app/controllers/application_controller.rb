class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper 
  
  # Messages are just a loose wrapper around XML or JSON blobs used for error messages or success messages when 
  # there are no data types to be returned. 
  class Message
    def initialize(text,code)
      @info = {:text => text, :code => code.to_i}
    end

    def to_xml(opts)
      @info.to_xml(opts.merge!(:root => 'message')) 
    end

    def to_json
      @info.to_json
    end

    def text
      @info[:text]
    end
  end 
  
  def respond_to_user(message_text,code,path)
    m = Message.new(message_text,code)
    if request.env["HTTP_USER_AGENT"].include? 'iPhone'
      render :xml => m
    else
      respond_to do | format |     
        format.html do 
          if code == 0
            flash[:message] = m.text
          else
            flash[:error] = m.text
          end
          redirect_to path
        end
      end
    end
  end
end
