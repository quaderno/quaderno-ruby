module Quaderno
  module Behavior
    module Deliver
  
      def self.included(base)
        base.send :include, InstanceMethods
      end
      
      module InstanceMethods
        def deliver
          party_response = api_model.get("#{api_model.base_url}/#{ api_model.subdomain }/api/v1/#{ api_model.api_path }/#{ id }/deliver.json", basic_auth: { username: api_model.auth_token })
          api_model.check_exception_for(party_response, { rate_limit: true, subdomain_or_token: true, id: true, required_fields: true })
          { limit: party_response.headers["x-ratelimit-limit"].to_i, remaining: party_response.headers["x-ratelimit-remaining"].to_i }
        end 
      end
    end
  end
end