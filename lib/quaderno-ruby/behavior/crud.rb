require 'ruby-debug'
module Quaderno
  module Behavior
    module Crud         
      def self.included(receiver)
        receiver.send :extend, ClassMethods
      end
    
      module ClassMethods
        
        def all
          party_response = get("/#{ api_model.subdomain }/api/v1/#{ api_model.api_path }.json", basic_auth: { username: api_model.auth_token })
          api_model.set_rate_limit_info(party_response.headers["x-ratelimit-limit"].to_i, party_response.headers["x-ratelimit-remaining"].to_i)
          array = JSON::parse party_response.body
          collection = []
          array.each do |element|
            collection << (new element)
          end
          collection
        end

        def find(id)
          party_response = get "/#{ api_model.subdomain }/api/v1/#{ api_model.api_path }/#{ id }.json", basic_auth: { username: api_model.auth_token }
          api_model.set_rate_limit_info(party_response.headers["x-ratelimit-limit"].to_i, party_response.headers["x-ratelimit-remaining"].to_i)
          new JSON::parse party_response.body
        end

        def create(params)
          party_response = post "/#{ api_model.subdomain }/api/v1/#{ api_model.api_path }.json", body: params, basic_auth: { username: api_model.auth_token }
          api_model.set_rate_limit_info(party_response.headers["x-ratelimit-limit"].to_i, party_response.headers["x-ratelimit-remaining"].to_i)
          new JSON::parse party_response.body
        end

        def update(id, params)
          party_response = put "/#{ api_model.subdomain }/api/v1/#{ api_model.api_path }/#{ id }.json", body: params, basic_auth: { username: api_model.auth_token }
          api_model.set_rate_limit_info(party_response.headers["x-ratelimit-limit"].to_i, party_response.headers["x-ratelimit-remaining"].to_i)
          new JSON::parse party_response.body
        end

        def delete(id)
          party_response = HTTParty.delete "#{api_model.base_uri}/#{ api_model.subdomain }/api/v1/#{ api_model.api_path }/#{ id }.json", basic_auth: { username: api_model.auth_token }
          api_model.set_rate_limit_info(party_response.headers["x-ratelimit-limit"].to_i, party_response.headers["x-ratelimit-remaining"].to_i)
        end
      end
    end
  end
end
