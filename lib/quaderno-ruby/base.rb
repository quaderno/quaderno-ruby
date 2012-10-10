module Quaderno
  require 'httparty'
  require 'json'
  
  class Base < OpenStruct
    include HTTParty
    include Quaderno::Exceptions
    include Quaderno::Behavior::Crud    
    
    base_uri 'http://localhost:3000/' 
    @@auth_token = nil 
    @@subdomain = nil
    @@rate_limit_info = 'Unknown. This information will be available after your first request'
      
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
    

    #Returns the rate limit information: limit and remaining requests
    def self.rate_limit_info
      @@rate_limit_info 
    end
    
    private 
    def self.set_rate_limit_info(rate_limit, remaining_rate_limit)
      @@rate_limit_info = { limit: rate_limit, remaining: remaining_rate_limit }
    end
    
    def self.auth_token
      @@auth_token
    end
    
    def self.subdomain
      @_subdomain = @@subdomain
    end
    
    def self.api_path(api_path = nil)
      @_api_path ||= api_path
    end
  end
end