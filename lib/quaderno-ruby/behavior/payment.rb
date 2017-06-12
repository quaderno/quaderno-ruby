module Quaderno
  module Behavior
    module Payment

      def self.included(base)
        base.send :include, InstanceMethods
      end

      module InstanceMethods
        include Quaderno::Helpers::Authentication

        def add_payment(params)
          self.authentication_data = get_authentication(options.merge(api_model: api_model)) if options.is_a?(Hash)

          response = api_model.post("#{authentication_data[:url]}#{api_model.api_path}/#{id}/payments.json",
            body: params,
            basic_auth: authentication_data[:basic_auth],
            headers: self.class.version_header.merge(authentication_data[:headers])
          )

          api_model.check_exception_for(response, { rate_limit: true, subdomain_or_token: true, required_fields: true })

          instance = Quaderno::Payment.new(response.parsed_response)
          self.payments << instance

          Quaderno::Payment.new instance
        end

        def remove_payment(payment_id)
          response = HTTParty.delete("#{authentication_data[:url]}#{api_model.api_path}/#{id}/payments/#{payment_id}.json",
            basic_auth: authentication_data[:basic_auth],
            headers: self.class.version_header.merge(authentication_data[:headers])
          )

          api_model.check_exception_for(response, { rate_limit: true, subdomain_or_token: true, id: true })

          self.payments.delete_if { |payment| payment.id == payment_id }

          true
        end
      end
    end
  end
end