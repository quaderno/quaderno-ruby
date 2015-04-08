module Quaderno
  module Behavior
    module Crud
      def self.included(receiver)
        receiver.send :extend, ClassMethods
      end

      module ClassMethods
        def to_instance(klass, hash)
          klass.new hash
        end

        # Parse nested elements of a document
        def parse(element)
          payments_collection = []
          element['payments'].each do |payment|
            payments_collection << api_model.to_instance(Quaderno::Payment, payment)
          end unless api_model == Quaderno::Estimate
          element['payments'] = payments_collection

          items_collection = []
          element['items'].each do |item|
            items_collection << api_model.to_instance(Quaderno::DocumentItem, item)
          end
          element['items'] = items_collection

          contact = api_model.to_instance(Quaderno::Contact, element['contact'])
          element['contact'] = contact
        end

        def all(filter = nil)
          party_response = get("#{api_model.base_url}/api/v1/#{ api_model.api_path }.json", body: filter, basic_auth: { username: api_model.auth_token })
          check_exception_for(party_response,  { rate_limit: true, subdomain_or_token: true })
          array = party_response.parsed_response
          collection = []

          if is_a_document?
            array.each do |element|
              api_model.parse(element)
              collection << (new element)
            end
          else
            array.each { |element| collection << (new element) }
          end

          collection
        end

        def find(id)
          party_response = get "#{api_model.base_url}/api/v1/#{ api_model.api_path }/#{ id }.json", basic_auth: { username: api_model.auth_token }
          check_exception_for(party_response,  { rate_limit: true, subdomain_or_token: true, id: true })
          hash = party_response.parsed_response

          api_model.parse(hash) if is_a_document?

          new hash
        end

        def create(params)
          party_response = post "#{api_model.base_url}/api/v1/#{ api_model.api_path }.json", body: params, basic_auth: { username: api_model.auth_token }
          check_exception_for(party_response,  { rate_limit: true, subdomain_or_token: true, required_fields: true })
          hash = party_response.parsed_response

          api_model.parse(hash) if is_a_document

          new hash
        end

        def update(id, params)
          party_response = put "#{api_model.base_url}/api/v1/#{ api_model.api_path }/#{ id }.json", body: params, basic_auth: { username: api_model.auth_token }
          check_exception_for(party_response, { rate_limit: true, subdomain_or_token: true, id: true })
          hash = party_response.parsed_response

          api_model.parse(hash) if is_a_document?

          new hash
        end

        def delete(id)
          party_response = HTTParty.delete "#{api_model.base_url}/api/v1/#{ api_model.api_path }/#{ id }.json", basic_auth: { username: api_model.auth_token }
          check_exception_for(party_response,  { rate_limit: true, subdomain_or_token: true, id: true, has_documents: true })
          true
        end
      end
    end
  end
end
