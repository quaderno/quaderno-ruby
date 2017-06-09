module Quaderno
  module Behavior
    module Authentication

      def get_authentication(options = {})
        mode = options[:mode] || :production

        url = options[:url] || api_model.url || (mode == :production ? 'https://quadernoapp.com/api/' : 'http://sandbox-quadernoapp.com/api/')

        auth_token = options[:auth_token] || options['auth_token'] || api_model.auth_token
        access_token = options[:access_token] || options['access_token']

        authentication = { url: url, headers: {}, basic_auth: nil }

        if access_token
          authentication[:headers] = { 'Authorization' => "Bearer #{access_token}" }
        elsif auth_token
          authentication[:basic_auth] = { username: auth_token }
        end

        authentication
      end
    end
  end
end