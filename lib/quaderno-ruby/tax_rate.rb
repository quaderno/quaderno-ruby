# frozen_string_literal: true

class Quaderno::TaxRate < Quaderno::Base
  api_model Quaderno::TaxRate
  api_path 'tax_rates'

  def self.calculate(options = {})
    authentication = get_authentication(options.merge(api_model: api_model))
    params = options.dup.delete_if { |k, _| %w[auth_token access_token api_url mode api_model].include? k.to_s }

    response = get("#{authentication[:url]}#{api_path}/calculate.json",
      query: params,
      basic_auth: authentication[:basic_auth],
      headers: default_headers.merge(authentication[:headers])
    )

    check_exception_for(response, { rate_limit: true, subdomain_or_token: true, id: true })
    data = new response.parsed_response
    data.rate_limit_info = response

    data
  end
end
