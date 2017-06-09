module Quaderno
  module Behavior
    module Deliver

      def self.included(base)
        base.send :include, InstanceMethods
      end

      module InstanceMethods
        def deliver
          party_response = api_model.get("#{authentication_data[:url]}#{api_model.api_path}/#{id}/deliver.json",
            basic_auth: authentication_data[:basic_auth],
            headers: self.class.version_header.merge(authentication_data[:headers])
          )

          api_model.check_exception_for(party_response, { rate_limit: true, subdomain_or_token: true, id: true, required_fields: true })
          { limit: party_response.headers["x-ratelimit-limit"].to_i, remaining: party_response.headers["x-ratelimit-remaining"].to_i }
        end
      end
    end
  end
end