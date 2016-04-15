module Quaderno
  module Exceptions
    class InvalidSubdomainOrToken < Exception
    end

    class InvalidID < Exception
    end

    class RateLimitExceeded < Exception
    end

    class HasAssociatedDocuments < Exception
    end

    class RequiredFieldsEmptyOrInvalid < Exception
    end

    class ThrottleLimitExceeded < Exception
    end

    def self.included(receiver)
      receiver.send :extend, ClassMethods
    end  

    module ClassMethods
      def check_exception_for(party_response, params = {})
        if params[:throttle_limit].nil? == false
         raise(Quaderno::Exceptions::ThrottleLimitExceeded, 'Throttle limit exceeded, please try again later') if party_response.response.class == Net::HTTPServiceUnavailable 
        end
        if params[:rate_limit].nil? == false
          raise(Quaderno::Exceptions::RateLimitExceeded, 'Rate limit exceeded') if party_response.response.class == Net::HTTPForbidden
        end
        if params[:subdomain_or_token].nil? == false
          raise(Quaderno::Exceptions::InvalidSubdomainOrToken, 'Invalid subdomain or token') if party_response.response.class == Net::HTTPUnauthorized
        end
        if params[:id].nil? == false
          raise(Quaderno::Exceptions::InvalidID, "Invalid #{ api_model } instance identifier") if (party_response.response.class == Net::HTTPInternalServerError) || (party_response.response.class == Net::HTTPNotFound)
        end
        if params[:required_fields].nil? == false
          raise(Quaderno::Exceptions::RequiredFieldsEmptyOrInvalid, party_response.body) if party_response.response.class == Net::HTTPUnprocessableEntity
        end
        if params[:has_documents].nil? == false
          raise(Quaderno::Exceptions::HasAssociatedDocuments, party_response.body) if party_response.response.class == Net::HTTPClientError 
        end
      end
    end
  end
end