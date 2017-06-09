module Quaderno
  module Behavior
    module Payment

      def self.included(base)
        base.send :include, InstanceMethods
      end

      module InstanceMethods

        def add_payment(params)
          response = api_model.post "#{api_model.url}#{ api_model.api_path }/#{ id }/payments.json", body: params, basic_auth: { username: api_model.auth_token }, headers: self.class.version_header
          api_model.check_exception_for(response, { rate_limit: true, subdomain_or_token: true, required_fields: true })

          instance = Quaderno::Payment.new(response.parsed_response)
          self.payments << instance

          Quaderno::Payment.new instance
        end

        def remove_payment(payment_id)
          response = HTTParty.delete "#{api_model.url}#{ api_model.api_path }/#{ id }/payments/#{ payment_id }.json", basic_auth: { username: api_model.auth_token }, headers: self.class.version_header
          api_model.check_exception_for(response, { rate_limit: true, subdomain_or_token: true, id: true })

          self.payments.delete_if { |payment| payment.id == payment_id }

          true
        end
      end
    end
  end
end