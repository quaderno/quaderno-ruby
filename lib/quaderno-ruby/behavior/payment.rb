module Quaderno
  module Behavior
    module Payment 
      def self.included(base)
        base.send :include, InstanceMethods
      end
      
      module InstanceMethods
        def to_instance(klass, parsed)
          klass.new(parsed)
        end
        
        def add_payment(params)
          party_response = api_model.post "/#{ api_model.subdomain }/api/v1/#{ api_model.api_path }/#{ id }/payments.json", body: params, basic_auth: { username: api_model.auth_token }
          parsed = JSON::parse party_response.body
          instance = to_instance(Quaderno::Payment, parsed)
          debugger
          payments << instance
          api_model.set_rate_limit_info(party_response.headers["x-ratelimit-limit"].to_i, party_response.headers["x-ratelimit-remaining"].to_i)
          Quaderno::Payment.new parsed
        end

        def remove_payment(payment_id)
          party_response = HTTParty.delete "#{ api_model.base_uri }/#{ api_model.subdomain }/api/v1/#{ api_model.api_path }/#{ id }/payments/#{ payment_id }.json", basic_auth: { username: api_model.auth_token }
          api_model.set_rate_limit_info(party_response.headers["x-ratelimit-limit"].to_i, party_response.headers["x-ratelimit-remaining"].to_i)
        end
      end
    end
  end
end