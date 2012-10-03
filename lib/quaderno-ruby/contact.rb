module Quaderno
  class Contact < Base
    #include Quaderno::Behavior::Crud
    
    api_path 'contacts'
    
    def self.all
      party_response = get "/#{ @@subdomain }/api/v1/contacts.json", basic_auth: { username: @@auth_token }
      array = JSON::parse party_response.body
      collection = []
      array.each do |element|
        collection << (new element)
      end
      collection
    end
    
    def self.find(contact_id)
      party_response = get "/#{ @@subdomain }/api/v1/contacts/#{ contact_id }.json", basic_auth: { username: @@auth_token }
      @@rate_limit = party_response.headers["x-ratelimit-limit"]
      @@remaining_rate_limit = party_response.headers["x-ratelimit-remaining"]
      new JSON::parse party_response.body
    end

    def self.create(params)
      party_response = post "/#{ @@subdomain }/api/v1/contacts.json", body: params, basic_auth: { username: @@auth_token }
      new JSON::parse party_response.body
    end

    def self.update(id, params)
      party_response = put "/#{ @@subdomain }/api/v1/contacts/#{ id }.json", body: params, basic_auth: { username: @@auth_token }
      new JSON::parse party_response.body
    end
    
    def self.delete(id)
      HTTParty.delete "#{Contact.base_uri}/#{ @@subdomain }/api/v1/contacts/#{ id }.json", basic_auth: { username: @@auth_token }
    end
  end
end