# frozen_string_literal: true

class Quaderno::Account < Quaderno::Base
  class << self
    undef :delete
  end

  api_model Quaderno::Account
  api_path 'accounts'

  def self.activate(id, options = {})
    setup_account('activate', id, options)
  end

  def self.deactivate(id, options = {})
    setup_account('deactivate', id, options)
  end

  private_class_method def self.setup_account(mode, id, options)
    authentication = get_authentication(options.merge(api_model: api_model))

    response = put("#{authentication[:url]}#{api_model.api_path}/#{id}/#{mode}.json", {
      basic_auth: authentication[:basic_auth],
      headers: default_headers.merge(authentication[:headers]).merge('Content-Type' => 'application/json')
    })

    check_exception_for(response, { rate_limit: true, required_fields: true, subdomain_or_token: true, id: true })

    hash = response.parsed_response
    hash[:authentication_data] = authentication

    object = new hash
    object.rate_limit_info = response

    object
  end
end
