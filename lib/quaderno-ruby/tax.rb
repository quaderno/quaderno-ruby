module Quaderno
  class Tax < Base
    api_model Quaderno::Tax
    api_path 'taxes'
    
    class << self
      undef :all, :find, :create, :update, :delete, :parse
    end
    
    def self.calculate(params)
      party_response = get("#{self.url}taxes/calculate.json", query: params, basic_auth: { username: api_model.auth_token } )
      check_exception_for(party_response, { rate_limit: true, subdomain_or_token: true, id: true })
      new party_response.parsed_response
    end
  end
end