module Quaderno
  module Behavior
    module Retrieve
      def self.included(receiver)
        receiver.send :extend, ClassMethods
      end

      module ClassMethods

        def retrieve(gateway_id, gateway = nil)
          response = get "#{api_model.url}#{gateway || 'stripe'}/#{@_retrieve_path}/#{gateway_id}.json", basic_auth: { username: api_model.auth_token }, headers: version_header
          check_exception_for(response, { rate_limit: true, subdomain_or_token: true, id: true })
          hash = response.parsed_response

          new hash
        end
        alias_method :retrieve_customer, :retrieve

        private
        def retrieve_path(path)
          @_retrieve_path = path
        end
      end
    end
  end
end