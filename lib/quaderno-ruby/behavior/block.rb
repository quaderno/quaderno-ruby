module Quaderno
  module Behavior
    module Block
      def self.included(receiver)
        receiver.send :extend, ClassMethods
      end

      module ClassMethods
        include Quaderno::Helpers::Authentication

        def block(id, options = {})
          authentication = get_authentication(options.merge(api_model: api_model))


          response = put("#{authentication[:url]}#{api_model.api_path}/#{id}/block.json",
            basic_auth: authentication[:basic_auth],
            headers: version_header.merge(authentication[:headers])
          )

          check_exception_for(response, { rate_limit: true, subdomain_or_token: true, id: true })
          doc = response.parsed_response

          new doc
        end
      end
    end
  end
end