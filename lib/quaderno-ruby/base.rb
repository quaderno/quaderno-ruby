# frozen_string_literal: true

require 'httparty'
require 'json'

class Quaderno::Base < OpenStruct
  include HTTParty
  include Quaderno::Exceptions
  include Quaderno::Behavior::Crud
  include Quaderno::Helpers::Authentication
  include Quaderno::Helpers::RateLimit

  PRODUCTION_URL = 'https://quadernoapp.com/api/'
  SANDBOX_URL = 'http://sandbox-quadernoapp.com/api/'

  @@auth_token = nil
  @@rate_limit_info = nil
  @@api_version = nil
  @@url = PRODUCTION_URL
  @@user_agent_suffix = nil

  # Class methods
  def self.api_model(klass)
    instance_eval <<-END
      def api_model
        #{klass}
      end
    END
    class_eval <<-END
      def api_model
        #{klass}
      end
    END
  end

  def self.configure
    yield self
  end

  def self.api_version=(api_version)
    @@api_version = api_version
  end

  def self.auth_token=(auth_token)
    @@auth_token = auth_token
  end

  def self.url=(url)
    @@url = url
  end

  def self.user_agent_header=(custom_user_agent)
    @@user_agent_suffix = custom_user_agent
  end

  def self.authorization(auth_token, mode = nil)
    mode ||= :production
    url = mode == :sandbox ? SANDBOX_URL : PRODUCTION_URL
    response = get("#{url}authorization.json", basic_auth: { username: auth_token }, headers: default_headers)

    if response.code == 200
      data = self.new(response.parsed_response)
      data.rate_limit_info = response

      data
    elsif response.response.is_a?(Net::HTTPServerError)
      raise_exception(Quaderno::Exceptions::ServerError, 'Server error', response)
    else
      raise_exception(Quaderno::Exceptions::InvalidSubdomainOrToken, 'Invalid subdomain or token', response)
    end
  end

  #Check the connection
  def self.ping(options = {})
    begin
      options[:auth_token] ||= auth_token
      options[:api_url] ||= url

      authentication = get_authentication(options)

      party_response = get("#{authentication[:url]}ping.json",
        basic_auth: authentication[:basic_auth],
        headers: default_headers.merge(authentication[:headers])
      )

      check_exception_for(party_response, { subdomain_or_token: true })
    rescue Errno::ECONNREFUSED
      return Quaderno::Base.new({ status: false })
    end

    data = self.new({ status: true })
    data.rate_limit_info = party_response

    data
  end
  class <<self
    alias_method :rate_limit_info, :ping
  end

  def self.me(options = {})
    options[:auth_token] ||= auth_token
    options[:api_url] ||= url

    authentication = get_authentication(options)

    party_response = get("#{authentication[:url]}me.json",
      basic_auth: authentication[:basic_auth],
      headers: default_headers.merge(authentication[:headers])
    )

    check_exception_for(party_response, { subdomain_or_token: true })

    data = self.new(party_response.parsed_response)
    data.rate_limit_info = party_response

    data
  end

  # Instance methods
  def to_hash
    self.marshal_dump
  end

  private
  # Class methods
  def self.auth_token
    @@auth_token
  end

  def self.url
    @@url
  end

  def self.subdomain
    @_subdomain = @@subdomain
  end

  #Set or returns the model path for the url
  def self.api_path(api_path = nil)
    @_api_path ||= api_path
  end

  def self.is_a_document?(document = nil)
    @_document ||= document
  end

  def self.default_headers
    user_agent_header.merge(version_header)
  end

  def self.user_agent_header
    { "User-Agent" => ["Quaderno Ruby Gem #{Quaderno::VERSION}", @@user_agent_suffix].compact.join(' - ') }
  end

  def self.version_header
    { 'Accept' => @@api_version.to_i.zero? ? "application/json" : "application/json; api_version=#{@@api_version.to_i}"}
  end

  headers self.default_headers
end
