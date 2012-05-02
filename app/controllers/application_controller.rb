class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper 
  
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
