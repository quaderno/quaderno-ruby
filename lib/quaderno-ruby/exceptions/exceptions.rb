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

  class ServerError < BaseException
  end

  def self.included(receiver)
    receiver.send :extend, ClassMethods
  end

  module ClassMethods
    def check_exception_for(party_response, params = {})
      raise_exception(Quaderno::Exceptions::UnsupportedApiVersion, 'Unsupported API version', party_response) if !!(party_response.body =~ /Unsupported API version/)

      if params[:throttle_limit].nil? == false && party_response.response.instance_of?(Net::HTTPServiceUnavailable)
        raise_exception(Quaderno::Exceptions::ThrottleLimitExceeded, 'Throttle limit exceeded, please try again later', party_response)
      end

      if params[:rate_limit].nil? == false && party_response.response.instance_of?(Net::HTTPForbidden)
        raise_exception(Quaderno::Exceptions::RateLimitExceeded, 'Rate limit exceeded', party_response)
      end

      if params[:subdomain_or_token].nil? == false && party_response.response.instance_of?(Net::HTTPUnauthorized)
        raise_exception(Quaderno::Exceptions::InvalidSubdomainOrToken, 'Invalid subdomain or token', party_response)
      end

      if params[:id].nil? == false && (party_response.response.instance_of?(Net::HTTPInternalServerError) || party_response.response.instance_of?(Net::HTTPNotFound))
        raise_exception(Quaderno::Exceptions::InvalidID, "Invalid #{api_model} instance identifier", party_response)
      end

      if params[:required_fields].nil? == false && party_response.response.instance_of?(Net::HTTPUnprocessableEntity)
        raise_exception(Quaderno::Exceptions::RequiredFieldsEmptyOrInvalid, party_response.body, party_response)
      end

      if party_response.response.instance_of?(Net::HTTPBadRequest)
        raise_exception(Quaderno::Exceptions::RequiredFieldsEmptyOrInvalid, party_response.body, party_response)
      end

      if params[:has_documents].nil? == false && party_response.response.instance_of?(Net::HTTPClientError)
        raise_exception(Quaderno::Exceptions::HasAssociatedDocuments, party_response.body, party_response)
      end

      raise_exception(Quaderno::Exceptions::ServerError, 'Server error', party_response) if party_response.response.is_a?(Net::HTTPServerError)
    end

    def raise_exception(klass, message, response)
      exception = klass.new(message)
      exception.rate_limit_info = response

      raise exception
    end
  end
end
