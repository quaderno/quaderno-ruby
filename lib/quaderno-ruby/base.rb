module Quaderno
  require 'httparty'
  require 'json'
  
  class Base < OpenStruct
    include HTTParty
    include Quaderno::Exceptions
    include Quaderno::Behavior::Crud    
    
    base_uri 'https://quadernoapp.com/'
    @@auth_token = nil 
    @@subdomain = nil
    @@rate_limit_info = nil
      
    def self.api_model(klass)
      instance_eval <<-END
        def api_model
          #{klass}
        end
      END
      class_eval <<-END
        def api_model
          #{klass}
        end
      END
    end
    
    #Default way to configure the authenticata data
    def self.configure
      yield self
    end
     
    def self.auth_token=(auth_token)
      @@auth_token = auth_token
    end
    
    def self.subdomain=(subdomain)
      @@subdomain = subdomain
    end
    
    #Check the connection
    def self.ping
      begin
        party_response = get("/#{ subdomain }/api/v1/ping.json", basic_auth: { username: auth_token })
      rescue Errno::ECONNREFUSED
        return false
      end
      true
    end
    
    #Returns the rate limit information: limit and remaining requests
    def self.rate_limit_info
      party_response = get("/#{ subdomain }/api/v1/ping.json", basic_auth: { username: auth_token })
      @@rate_limit_info = { limit: party_response.headers["x-ratelimit-limit"].to_i, remaining: party_response.headers["x-ratelimit-remaining"].to_i }
    end
    
    
    private 
    def self.auth_token
      @@auth_token
    end
    
    def self.subdomain
      @_subdomain = @@subdomain
    end
    #Set or returns the model path for the url
    def self.api_path(api_path = nil)
      @_api_path ||= api_path
    end
  end
end