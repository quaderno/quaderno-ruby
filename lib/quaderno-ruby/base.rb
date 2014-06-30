module Quaderno
  require 'httparty'
  require 'json'
  
  class Base < OpenStruct
    include HTTParty
    include Quaderno::Exceptions
    include Quaderno::Behavior::Crud    
    
    @@auth_token = nil 
    @@subdomain = nil
    @@rate_limit_info = nil
    @@base_url = nil
    @@environment = :production

    # Class methods
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
    
    def self.configure
      yield self
      @@base_url = @@environment == :sandbox && !@@subdomain.nil? ? "http://#{@@subdomain}.sandbox-quadernoapp.com" : "https://#{@@subdomain}.quadernoapp.com"
    end
     
    def self.environment=(mode)
      @@environment = mode
    end

    def self.auth_token=(auth_token)
      @@auth_token = auth_token
    end
    
    def self.subdomain=(subdomain)
      @@subdomain = subdomain
    end
    
    def self.authorization(auth_token, mode = nil)
      begin
        mode ||= @@environment
        base_url = mode == :sandbox ? 'http://sandbox-quadernoapp.com' : 'https://quadernoapp.com'
        party_response = get("#{base_url}/api/v1/authorization.json", basic_auth: { username: auth_token })
        return  JSON::parse party_response.body
      rescue Exception
        return false
      end
    end

    #Check the connection
    def self.ping
      begin
        party_response = get("#{@@base_url}/api/v1/ping.json", basic_auth: { username: auth_token })
      rescue Errno::ECONNREFUSED
        return false
      end
      true
    end
    
    #Returns the rate limit information: limit and remaining requests
    def self.rate_limit_info
      party_response = get("#{@@base_url}/api/v1/ping.json", basic_auth: { username: auth_token })
      @@rate_limit_info = { limit: party_response.headers["x-ratelimit-limit"].to_i, remaining: party_response.headers["x-ratelimit-remaining"].to_i }
    end
    

    # Instance methods
    def to_hash
      self.marshal_dump
    end
    
    private
    def self.auth_token
      @@auth_token
    end

    def self.base_url
      @@base_url
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