# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

module OmniAuth
  module Strategies
    class Facebook < OAuth2

      # debug: added gecko to test in browser
      MOBILE_USER_AGENTS =  'webos|ipod|iphone|mobile|gecko'

      def request_phase
        options[:scope] ||= "email,offline_access"
        options[:display] = mobile_request? ? 'touch' : 'page'
        super
      end

      def mobile_request?
        ua = Rack::Request.new(@env).user_agent.to_s
        ua.downcase =~ Regexp.new(MOBILE_USER_AGENTS)
      end

    end
  end
end

run MapsqueakProto::Application
