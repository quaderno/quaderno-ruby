module Quaderno::Behavior
  module Deliver

    def self.included(base)
      base.send :include, InstanceMethods
    end

    module InstanceMethods
      include Quaderno::Helpers::Authentication

      def deliver(options = nil)
        self.authentication_data = get_authentication(options.merge(api_model: api_model)) if options.is_a?(Hash)

        party_response = api_model.get("#{authentication_data[:url]}#{api_model.api_path}/#{id}/deliver.json",
          basic_auth: authentication_data[:basic_auth],
          headers: self.class.default_headers.merge(authentication_data[:headers])
        )

        api_model.check_exception_for(party_response, { rate_limit: true, subdomain_or_token: true, id: true, required_fields: true })

        data = Quaderno::Base.new(success: true)
        data.rate_limit_info = party_response

        data
      end
    end
  end
end
