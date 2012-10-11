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
          api_model.check_exception_for(party_response, { rate_limit: true, subdomain_or_token: true, required_fields: true })
          parsed = JSON::parse party_response.body
          instance = to_instance(Quaderno::Payment, parsed)
          payments << instance
          Quaderno::Payment.new parsed
        end

        def remove_payment(payment_id)
          party_response = HTTParty.delete "#{ api_model.base_uri }/#{ api_model.subdomain }/api/v1/#{ api_model.api_path }/#{ id }/payments/#{ payment_id }.json", basic_auth: { username: api_model.auth_token }
          to_delete = nil
          payments.each do |payment|
            if payment.id == payment_id
              to_delete = payment
              break
            end
          end
          payments.delete(to_delete)
          api_model.check_exception_for(party_response, { rate_limit: true, subdomain_or_token: true, id: true }) 
          true
        end
      end
    end
  end
end