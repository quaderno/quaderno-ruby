module Quaderno::Exceptions
  class BaseException < StandardError
    include Quaderno::Helpers::RateLimit
  end

  class InvalidSubdomainOrToken < BaseException
  end

  class InvalidID < BaseException
  end

  class RateLimitExceeded < BaseException
  end

  class HasAssociatedDocuments < BaseException
  end

  class RequiredFieldsEmptyOrInvalid < BaseException
  end

  class ThrottleLimitExceeded < BaseException
  end

  class UnsupportedApiVersion < BaseException
  end

  def self.included(receiver)
    receiver.send :extend, ClassMethods
  end

  module ClassMethods
    def check_exception_for(party_response, params = {})
      raise_exception(Quaderno::Exceptions::UnsupportedApiVersion, 'Unsupported API version', party_response) if !!(party_response.body =~ /Unsupported API version/)

      if params[:throttle_limit].nil? == false && party_response.response.class == Net::HTTPServiceUnavailable
        raise_exception(Quaderno::Exceptions::ThrottleLimitExceeded, 'Throttle limit exceeded, please try again later', party_response)
      end
      if params[:rate_limit].nil? == false && party_response.response.class == Net::HTTPForbidden
        raise_exception(Quaderno::Exceptions::RateLimitExceeded, 'Rate limit exceeded', party_response)
      end
      if params[:subdomain_or_token].nil? == false
        raise_exception(Quaderno::Exceptions::InvalidSubdomainOrToken, 'Invalid subdomain or token', party_response) if party_response.response.class == Net::HTTPUnauthorized
      end
      if params[:id].nil? == false
        raise_exception(Quaderno::Exceptions::InvalidID, "Invalid #{ api_model } instance identifier", party_response) if (party_response.response.class == Net::HTTPInternalServerError) || (party_response.response.class == Net::HTTPNotFound)
      end
      if params[:required_fields].nil? == false
        raise_exception(Quaderno::Exceptions::RequiredFieldsEmptyOrInvalid, party_response.body, party_response) if party_response.response.class == Net::HTTPUnprocessableEntity
      end
      if params[:has_documents].nil? == false
        raise_exception(Quaderno::Exceptions::HasAssociatedDocuments, party_response.body, party_response) if party_response.response.class == Net::HTTPClientError
      end
    end

    def raise_exception(klass, message, response)
      exception = klass.new(message)
      exception.rate_limit_info = response

      raise exception
    end
  end
end
