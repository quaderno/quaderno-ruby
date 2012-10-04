module Quaderno
  class Estimate < Base
    include Quaderno::Behavior::Crud    
    
    api_model Quaderno::Estimate
    api_path 'estimates'
    
    def self.deliver(id)
      party_response = get("/#{ subdomain }/api/v1/estimates/#{ id }/deliver.json", basic_auth: { username: auth_token })
      api_model.set_rate_limit_info(party_response.headers["x-ratelimit-limit"].to_i, party_response.headers["x-ratelimit-remaining"].to_i)
    end      
  end
end