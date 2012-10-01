module Quaderno
  class Base
    include HTTParty
    base_uri 'http://localhost:3000/' 
    @@auth_token = nil 
    @@subdomain = nil
   
    def self.init(auth_token, subdomain)
      @@auth_token = auth_token
      @@subdomain = subdomain
    end
    
    def contacts
      self.class.get "/uruk-628/api/v1/contacts.json", basic_auth: @@auth_token 
    end
  end
end