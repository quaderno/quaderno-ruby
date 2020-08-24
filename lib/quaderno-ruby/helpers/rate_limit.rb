module Quaderno::Helpers
  module RateLimit

    def rate_limit_info=(response)
      @rate_limit_info = { reset: response.headers['x-ratelimit-reset'].to_i, remaining: response.headers["x-ratelimit-remaining"].to_i }
    end

    def rate_limit_info
      @rate_limit_info
    end
  end
end