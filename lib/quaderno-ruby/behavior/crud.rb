module Quaderno
  module Behavior
    module Crud

      def self.included(receiver)
        receiver.send :extend, ClassMethods
      end

      module ClassMethods
        include Quaderno::Helpers::Authentication

        def parse_nested(element)
          if element.has_key?('payments')
            payments_collection = Array.new
            (element['payments'] || Array.new).each { |payment| payments_collection << Quaderno::Payment.new(payment) }
            element['payments'] = payments_collection
          end

          items_collection = Array.new
          element['items'].each { |item| items_collection << Quaderno::DocumentItem.new(item) }
          element['items'] = items_collection
          element['contact'] = Quaderno::Contact.new(element['contact'])

          element
        end

        def all(options = {})
          authentication = get_authentication(options.merge(api_model: api_model))
          filter = options.delete_if { |k,v| %w(auth_token access_token url mode api_model).include? k.to_s }

          response = get("#{authentication[:url]}#{api_model.api_path}.json",
            query: filter,
            basic_auth: authentication[:basic_auth],
            headers: version_header.merge(authentication[:headers])
          )

          check_exception_for(response, { rate_limit: true, subdomain_or_token: true })
          array = response.parsed_response
          collection = Array.new

          if is_a_document?
            array.each do |element|
              api_model.parse_nested(element)
              collection << (new element)
            end
          else
            array.each { |element| collection << (new element) }
          end

          collection
        end

        def find(id, options = {})
          authentication = get_authentication(options.merge(api_model: api_model))

          response = get("#{authentication[:url]}#{api_model.api_path}/#{id}.json",
            basic_auth: authentication[:basic_auth],
            headers: version_header.merge(authentication[:headers])
          )

          check_exception_for(response, { rate_limit: true, subdomain_or_token: true, id: true })
          hash = response.parsed_response

          api_model.parse_nested(hash) if is_a_document?

          new hash
        end

        def create(params = {})
          authentication = get_authentication(params.merge(api_model: api_model))
          params.delete_if { |k,v| %w(auth_token access_token url mode api_model').include? k.to_s }

          response = post("#{authentication[:url]}#{api_model.api_path}.json",
            body: params.to_json,
            basic_auth: authentication[:basic_auth],
            headers: version_header.merge(authentication[:headers]).merge('Content-Type' => 'application/json')
          )

          check_exception_for(response, { rate_limit: true, subdomain_or_token: true, required_fields: true })
          hash = response.parsed_response

          api_model.parse_nested(hash) if is_a_document?

          new hash
        end

        def update(id, params = {})
          authentication = get_authentication(params.merge(api_model: api_model))
          params = params.delete_if { |k,v| %w(auth_token access_token url mode api_model').include? k.to_s }

          response = put("#{authentication[:url]}#{api_model.api_path}/#{id}.json",
            body: params.to_json,
            basic_auth: authentication[:basic_auth],
            headers: version_header.merge(authentication[:headers]).merge('Content-Type' => 'application/json')
          )

          check_exception_for(response, { rate_limit: true, required_fields: true, subdomain_or_token: true, id: true })
          hash = response.parsed_response

          api_model.parse_nested(hash) if is_a_document?

          new hash
        end

        def delete(id, options = {})
          authentication = get_authentication(options.merge(api_model: api_model))

          response = HTTParty.delete("#{authentication[:url]}#{ api_model.api_path }/#{ id }.json",
            basic_auth: authentication[:basic_auth],
            headers: version_header.merge(authentication[:headers])
          )
          check_exception_for(response, { rate_limit: true, subdomain_or_token: true, id: true, has_documents: true })

          true
        end
      end
    end
  end
end
