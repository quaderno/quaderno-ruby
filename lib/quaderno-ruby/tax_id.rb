# frozen_string_literal: true

class Quaderno::TaxId < Quaderno::Base
  api_model Quaderno::TaxId
  api_path 'tax_ids'
  is_a_document? false

  def self.validate(country, tax_id, options = {})
    authentication = get_authentication(options.merge(api_model: api_model))

    response = get("#{authentication[:url]}#{api_path}/validate.json",
      query: { country: country, tax_id: tax_id },
      basic_auth: authentication[:basic_auth],
      headers: default_headers.merge(authentication[:headers])
    )

    check_exception_for(response, { rate_limit: true, subdomain_or_token: true, id: true })

    data = new({ valid: response.parsed_response['valid'] })
    data.rate_limit_info = response

    data
  end
end
