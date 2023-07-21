# frozen_string_literal: true

module Quaderno::Behavior
  module Retrieve
    def self.included(receiver)
      receiver.send :extend, ClassMethods
    end

    module ClassMethods
      include Quaderno::Helpers::Authentication

      def retrieve(gateway_id, gateway = 'stripe', options = {})
        authentication = get_authentication(options.merge(api_model: api_model))

        response = get("#{authentication[:url]}#{gateway}/#{@_retrieve_path}/#{gateway_id}.json",
          basic_auth: authentication[:basic_auth],
          headers: default_headers.merge(authentication[:headers])
        )

        check_exception_for(response, { rate_limit: true, subdomain_or_token: true, id: true })
        hash = response.parsed_response
        hash[:authentication_data] = authentication

        object = new hash
        object.rate_limit_info = response

        object
      end

      private

      def retrieve_path(path)
        @_retrieve_path = path
      end
    end
  end
end
