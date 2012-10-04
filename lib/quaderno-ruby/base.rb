module Quaderno
  require 'httparty'
  require 'json'
  require 'ostruct'
  
  class Base < OpenStruct
    include HTTParty
    
    base_uri 'http://localhost:3000/' 
    @@auth_token = nil 
    @@subdomain = nil
    @@rate_limit_info = 'Unknown. This information will be available after your first request'
    @@api_path = nil

    def self.api_model(klass)
      instance_eval <<-END
        def api_model
          #{klass}
        end
      END
    end
    
    def self.init(auth_token, subdomain)
      @@auth_token = auth_token
      @@subdomain = subdomain
    end
    
    def self.set_rate_limit_info(rate_limit, remaining_rate_limit)
      @@rate_limit_info = { limit: rate_limit, remaining: remaining_rate_limit }
    end
    
    def self.rate_limit_info
      @@rate_limit_info 
    end
    
    def self.auth_token
      @@auth_token
    end
    
    def self.subdomain
      @@subdomain
    end
    
    def self.api_path(api_path = nil)
      @@api_path ||= api_path
    end
  end
end