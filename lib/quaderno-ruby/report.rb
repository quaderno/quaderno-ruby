module Quaderno
  class Report < Base
    api_model Quaderno::Report
    api_path 'reports'

    class << self
      undef :all, :find, :create, :update, :delete, :parse_nested
    end

    def self.journal(options = {})
      authentication = get_authentication(options.merge(api_model: api_model))
      filter = options.delete_if { |k,v| %w(auth_token access_token api_url mode api_model).include? k.to_s }

      response = get("#{authentication[:url]}#{api_model.api_path}/journal.json",
        query: filter,
        basic_auth: authentication[:basic_auth],
        headers: version_header.merge(authentication[:headers])
      )

      check_exception_for(response, { rate_limit: true, subdomain_or_token: true })

      response.parsed_response
    end

    def self.taxes(options = {})
      authentication = get_authentication(options.merge(api_model: api_model))
      filter = options.delete_if { |k,v| %w(auth_token access_token api_url mode api_model).include? k.to_s }

      response = get("#{authentication[:url]}#{api_model.api_path}/taxes.json",
        query: filter,
        basic_auth: authentication[:basic_auth],
        headers: version_header.merge(authentication[:headers])
      )

      check_exception_for(response, { rate_limit: true, subdomain_or_token: true })

      response.parsed_response
    end
  end
end