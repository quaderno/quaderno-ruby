module Quaderno
  require 'httparty'
  require 'json'
  require 'ostruct'
  
  class Base < OpenStruct
    include HTTParty
    
    base_uri 'http://localhost:3000/' 
    @@auth_token = nil 
    @@subdomain = nil
    @@rate_limit = nil
    @@remaining_rate_limit = nil
    @@api_path = nil
    
    class << self
      def api_model(klass)
        class_eval <<-END
          def api_model
            #{klass}
          end
        END
      end
    end
    
    def self.init(auth_token, subdomain)
      @@auth_token = auth_token
      @@subdomain = subdomain
    end
    
    def self.rate_limit
      rate_limit = { limit: @@rate_limit, remaining: @@remaining_rate_limit }
    end
    
    def auth_token
      @@auth_token
    end
    
    def subdomain
      @@sub_domain
    end
    
    def self.api_path(api_path)
      @@api_path = api_path
    end
  end
end