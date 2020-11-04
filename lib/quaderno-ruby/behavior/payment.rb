module Quaderno::Behavior
  module Payment

    def self.included(base)
      base.send :include, InstanceMethods
    end

    module InstanceMethods
      include Quaderno::Helpers::Authentication

      def add_payment(params = {})
        if (params.keys.map(&:to_s) & %w(auth_token access_token api_url mode api_model)).any?
          self.authentication_data = get_authentication(params.merge(api_model: api_model))
          params = params.dup.delete_if { |k, _| %w(auth_token access_token api_url mode api_model).include? k.to_s }
        end

        response = api_model.post("#{authentication_data[:url]}#{api_model.api_path}/#{id}/payments.json",
          body: params,
          basic_auth: authentication_data[:basic_auth],
          headers: self.class.version_header.merge(authentication_data[:headers])
        )

        api_model.check_exception_for(response, { rate_limit: true, subdomain_or_token: true, required_fields: true })

        instance = Quaderno::Payment.new(response.parsed_response)
        self.payments << instance

        instance.rate_limit_info = response

        instance
      end

      def remove_payment(payment_id, options = nil)
        self.authentication_data = get_authentication(options.merge(api_model: api_model)) if options.is_a?(Hash)

        response = HTTParty.delete("#{authentication_data[:url]}#{api_model.api_path}/#{id}/payments/#{payment_id}.json",
          basic_auth: authentication_data[:basic_auth],
          headers: self.class.version_header.merge(authentication_data[:headers])
        )

        api_model.check_exception_for(response, { rate_limit: true, subdomain_or_token: true, id: true })

        self.payments.delete_if { |payment| payment.id == payment_id }

        hash = { deleted: true, id: payment_id}

        object = Quaderno::Payment.new(hash)
        object.rate_limit_info = response

        object
      end
    end
  end
end
