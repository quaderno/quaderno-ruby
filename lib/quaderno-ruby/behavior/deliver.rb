module Quaderno
  module Behavior
    module Deliver

      def self.included(base)
        base.send :include, InstanceMethods
      end

      module InstanceMethods
        def deliver(options = {})
          options[:api_model] = api_model
          authentication = get_authentication(options.merge(api_model: api_model))

          party_response = api_model.get("#{authentication[:url]}#{api_model.api_path}/#{id}/deliver.json",
            basic_auth: authentication[:basic_auth],
            headers: self.class.version_header.merge(authentication[:headers])
          )

          api_model.check_exception_for(party_response, { rate_limit: true, subdomain_or_token: true, id: true, required_fields: true })
          { limit: party_response.headers["x-ratelimit-limit"].to_i, remaining: party_response.headers["x-ratelimit-remaining"].to_i }
        end
      end
    end
  end
end