# frozen_string_literal: true

class Quaderno::TaxReport < OpenStruct
end

class Quaderno::Tax < Quaderno::Base
  api_model Quaderno::Tax
  api_path 'taxes'

  class << self
    undef :find, :create, :update, :delete, :parse_nested
  end

  def self.calculate(options = {})
    authentication = get_authentication(options.merge(api_model: api_model))
    params = options.dup.delete_if { |k, _| %w[auth_token access_token api_url mode api_model].include? k.to_s }

    response = get("#{authentication[:url]}tax_rates/calculate.json",
      query: params,
      basic_auth: authentication[:basic_auth],
      headers: default_headers.merge(authentication[:headers])
    )

    check_exception_for(response, { rate_limit: true, subdomain_or_token: true, id: true })
    data = new response.parsed_response
    data.rate_limit_info = response

    data
  end

  def self.validate_tax_id(country, tax_id, options = {})
    authentication = get_authentication(options.merge(api_model: api_model))

    response = get("#{authentication[:url]}tax_ids/validate.json",
      query: { country: country, tax_id: tax_id },
      basic_auth: authentication[:basic_auth],
      headers: default_headers.merge(authentication[:headers])
    )

    check_exception_for(response, { rate_limit: true, subdomain_or_token: true, id: true })

    data = new({ valid: response.parsed_response['valid'] })
    data.rate_limit_info = response

    data
  end
  # TODO: Temporary alias to be removed in future releases
  self.singleton_class.send(:alias_method, :validate_vat_number, :validate_tax_id)

  def self.reports(options = {})
    authentication = get_authentication(options.merge(api_model: api_model))
    params = options.dup.delete_if { |k, _| %w[auth_token access_token api_url mode api_model].include? k.to_s }

    response = get("#{authentication[:url]}taxes/reports.json",
      query: params,
      basic_auth: authentication[:basic_auth],
      headers: default_headers.merge(authentication[:headers])
    )

    array = response.parsed_response
    collection = Quaderno::Collection.new
    collection.rate_limit_info = response
    collection.current_page = response.headers['x-pages-currentpage']
    collection.total_pages = response.headers['x-pages-totalpages']

    array.each { |report| collection << Quaderno::TaxReport.new(report) }

    check_exception_for(response, { rate_limit: true, subdomain_or_token: true, id: true })

    collection
  end
end
