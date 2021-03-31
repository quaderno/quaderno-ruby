class Quaderno::Report < Quaderno::Base
  api_model Quaderno::Report
  api_path 'reports'

  class << self
    undef :all, :find, :create, :update, :delete, :parse_nested
  end

  def self.journal(options = {})
    authentication = get_authentication(options.merge(api_model: api_model))
    filter = options.dup.delete_if { |k,v| %w(auth_token access_token api_url mode api_model).include? k.to_s }

    response = get("#{authentication[:url]}#{api_model.api_path}/journal.json",
      query: filter,
      basic_auth: authentication[:basic_auth],
      headers: default_headers.merge(authentication[:headers])
    )

    check_exception_for(response, { rate_limit: true, subdomain_or_token: true })

    response.parsed_response
  end

  def self.taxes(options = {})
    authentication = get_authentication(options.merge(api_model: api_model))
    filter = options.dup.delete_if { |k,v| %w(auth_token access_token api_url mode api_model).include? k.to_s }

    response = get("#{authentication[:url]}#{api_model.api_path}/taxes.json",
      query: filter,
      basic_auth: authentication[:basic_auth],
      headers: default_headers.merge(authentication[:headers])
    )

    check_exception_for(response, { rate_limit: true, subdomain_or_token: true })

    response.parsed_response
  end

  def self.domestic_taxes(options = {})
    request_tax_report('domestic_taxes', options)
  end

  def self.sales_taxes(options = {})
    request_tax_report('sales_taxes', options)
  end

  def self.vat_moss(options = {})
    request_tax_report('vat_moss', options)
  end

  def self.ec_sales(options = {})
    request_tax_report('ec_sales', options)
  end

  def self.international_taxes(options = {})
    request_tax_report('international_taxes', options)
  end

  private

  def self.request_tax_report(tax_report_type, options)
    authentication = get_authentication(options.merge(api_model: api_model))
    filter = options.dup.delete_if { |k,v| %w(auth_token access_token api_url mode api_model).include? k.to_s }

    response = get("#{authentication[:url]}#{api_model.api_path}/#{tax_report_type}.json",
      query: filter,
      basic_auth: authentication[:basic_auth],
      headers: default_headers.merge(authentication[:headers])
    )

    check_exception_for(response, { rate_limit: true, subdomain_or_token: true })

    collection = Array.new
    response.parsed_response.each { |tax_report| collection << self.new(tax_report) }

    collection
  end
end
