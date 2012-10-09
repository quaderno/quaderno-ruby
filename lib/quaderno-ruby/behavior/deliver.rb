require 'ruby-debug'
module Quaderno
  module Behavior
    module Deliver
  
      def self.included(receiver)
        receiver.send :extend, ClassMethods
      end
      
      module ClassMethods
        
        def deliver(id)
          party_response = get("/#{ api_model.subdomain }/api/v1/#{ api_model.api_path }/#{ id }/deliver.json", basic_auth: { username: api_model.auth_token })
          
          check_exception_for(party_response, { rate_limit: true, subdomain_or_token: true, id: true, required_fields: true })
          
          api_model.set_rate_limit_info(party_response.headers["x-ratelimit-limit"].to_i, party_response.headers["x-ratelimit-remaining"].to_i)
        end 
      end
    end
  end
end