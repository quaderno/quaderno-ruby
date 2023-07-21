# frozen_string_literal: true

module Quaderno::Behavior
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

      def all_from_url(url, options = {})
        authentication = get_authentication(api_model: api_model)

        response = get(url,
          basic_auth: authentication[:basic_auth],
          headers: default_headers.merge(authentication[:headers])
        )

        handle_all_response(response, authentication, options)
      end

      def all(options = {})
        authentication = get_authentication(options.merge(api_model: api_model))
        filter = options.dup.delete_if { |k,v| %w(auth_token access_token api_url mode api_model).include? k.to_s }

        response = get("#{authentication[:url]}#{api_model.api_path}.json",
          query: filter,
          basic_auth: authentication[:basic_auth],
          headers: default_headers.merge(authentication[:headers])
        )

        handle_all_response(response, authentication, options)
      end

      def find(id, options = {})
        authentication = get_authentication(options.merge(api_model: api_model))

        response = get("#{authentication[:url]}#{api_model.api_path}/#{id}.json",
          basic_auth: authentication[:basic_auth],
          headers: default_headers.merge(authentication[:headers])
        )

        check_exception_for(response, { rate_limit: true, subdomain_or_token: true, id: true })
        hash = response.parsed_response
        hash[:authentication_data] = authentication

        api_model.parse_nested(hash) if is_a_document?

        object = new hash
        object.rate_limit_info = response

        object
      end

      def create(params = {})
        authentication = get_authentication(params.merge(api_model: api_model))
        params = params.dup.delete_if { |k, _| %w[auth_token access_token api_url mode api_model].include? k.to_s }

        response = post("#{authentication[:url]}#{api_model.api_path}.json",
          body: params.to_json,
          basic_auth: authentication[:basic_auth],
          headers: default_headers.merge(authentication[:headers]).merge('Content-Type' => 'application/json')
        )

        check_exception_for(response, { rate_limit: true, subdomain_or_token: true, required_fields: true })
        hash = response.parsed_response
        hash[:authentication_data] = authentication

        api_model.parse_nested(hash) if is_a_document?

        object = new hash
        object.rate_limit_info = response

        object
      end

      def update(id, params = {})
        authentication = get_authentication(params.merge(api_model: api_model))
        params = params.dup.delete_if { |k, _| %w[auth_token access_token api_url mode api_model].include? k.to_s }

        response = put("#{authentication[:url]}#{api_model.api_path}/#{id}.json",
          body: params.to_json,
          basic_auth: authentication[:basic_auth],
          headers: default_headers.merge(authentication[:headers]).merge('Content-Type' => 'application/json')
        )

        check_exception_for(response, { rate_limit: true, required_fields: true, subdomain_or_token: true, id: true })
        hash = response.parsed_response
        hash[:authentication_data] = authentication

        api_model.parse_nested(hash) if is_a_document?

        object = new hash
        object.rate_limit_info = response

        object
      end

      def delete(id, options = {})
        authentication = get_authentication(options.merge(api_model: api_model))

        response = HTTParty.delete("#{authentication[:url]}#{api_model.api_path}/#{id}.json",
          basic_auth: authentication[:basic_auth],
          headers: default_headers.merge(authentication[:headers])
        )
        check_exception_for(response, { rate_limit: true, subdomain_or_token: true, id: true, has_documents: true })

        hash = { deleted: true, id: id }

        object = new hash
        object.rate_limit_info = response

        object
      end

      private

      def handle_all_response(response, authentication, request_options)
        check_exception_for(response, { rate_limit: true, subdomain_or_token: true })
        array = response.parsed_response
        collection = Quaderno::Collection.new

        if is_a_document?
          array.each do |element|
            element[:authentication_data] = authentication
            api_model.parse_nested(element)
            collection << (new element)
          end
        else
          array.each { |element| collection << (new element) }
        end

        collection.rate_limit_info = response
        collection.request_options = request_options
        collection.collection_type = self
        collection.has_more = response.headers['x-pages-hasmore']
        collection.next_page_url = response.headers['x-pages-nextpage']

        collection
      end
    end
  end
end
