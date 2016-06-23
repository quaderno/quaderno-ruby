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
          reload_self

          Quaderno::Payment.new parsed
        end

        def remove_payment(payment_id)
          response = HTTParty.delete "#{api_model.url}#{ api_model.api_path }/#{ id }/payments/#{ payment_id }.json", basic_auth: { username: api_model.auth_token }, headers: self.class.version_header
          api_model.check_exception_for(response, { rate_limit: true, subdomain_or_token: true, id: true })
          reload_self

          true
        end

        private
        def reload_self
          reloaded_self = api_model.find(id)
          reloaded_self.each_pair { |k, v| self.send("#{k}=", v) }
        end
      end
    end
  end
end