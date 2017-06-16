module Quaderno
  class TaxReport < OpenStruct
  end

  class Tax < Base
    api_model Quaderno::Tax
    api_path 'taxes'

    class << self
      undef :all, :find, :create, :update, :delete, :parse_nested
    end

    def self.calculate(options = {})
      authentication = get_authentication(options.merge(api_model: api_model))
      params = options.delete_if { |k,v| %w(auth_token access_token api_url mode api_model).include? k.to_s }

      response = get("#{authentication[:url]}taxes/calculate.json",
        query: params,
        basic_auth: authentication[:basic_auth],
        headers: authentication[:headers]
      )

      check_exception_for(response, { rate_limit: true, subdomain_or_token: true, id: true })
      new response.parsed_response
    end

    def self.validate_vat_number(country, vat_number, options = {})
      authentication = get_authentication(options.merge(api_model: api_model))

      response = get("#{authentication[:url]}taxes/validate.json",
        query: { country: country, vat_number: vat_number },
        basic_auth: authentication[:basic_auth],
        headers: authentication[:headers]
      )

      check_exception_for(response, { rate_limit: true, subdomain_or_token: true, id: true })

      response.parsed_response['valid']
    end

    def self.reports(options = {})
      authentication = get_authentication(options.merge(api_model: api_model))
      params = options.delete_if { |k,v| %w(auth_token access_token api_url mode api_model).include? k.to_s }

      response = get("#{authentication[:url]}taxes/reports.json",
        query: params,
        basic_auth: authentication[:basic_auth],
        headers: authentication[:headers]
      )

      array = response.parsed_response
      collection = Quaderno::Collection.new
      collection.current_page = response.headers['x-pages-currentpage']
      collection.total_pages = response.headers['x-pages-totalpages']

      array.each { |report| collection << Quaderno::TaxReport.new(report) }

      check_exception_for(response, { rate_limit: true, subdomain_or_token: true, id: true })

      collection
    end
  end
end