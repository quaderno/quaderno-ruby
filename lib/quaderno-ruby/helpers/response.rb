# frozen_string_literal: true

module Quaderno::Helpers
  module Response
    def response_body=(response)
      @response_body = response
    end

    def response_body
      @response_body
    end
  end
end
