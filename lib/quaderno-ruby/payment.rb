module Quaderno
  class Payment < Base
        
    api_model Quaderno::Payment
    api_path 'payments'
    
    def create(id, params)
      party_response = post "/#{ subdomain }/api/v1/payments/#{ id }/payments.json", body: params, basic_auth: { username: auth_token }
      api_model.set_rate_limit_info(party_response.headers["x-ratelimit-limit"].to_i, party_response.headers["x-ratelimit-remaining"].to_i)
      new JSON::parse party_response.body
    end
    
    def delete(id)
      party_response = HTTParty.delete "#{ base_uri }/#{ subdomain }/api/v1/payments/#{ id }/payments.json", basic_auth: { username: auth_token }
      api_model.set_rate_limit_info(party_response.headers["x-ratelimit-limit"].to_i, party_response.headers["x-ratelimit-remaining"].to_i)
    end
  end
end