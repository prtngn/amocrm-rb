module AmoCRMClient
  module Http
    class Base
      include HTTParty
      default_timeout 5

      def initialize(host, options = {})
        self.class.base_uri host
        self.class.default_options.merge!(options)
      end

      def handle_response(response)
        raise UnauthorizedRequest if response.code == 401
        raise Forbidden if response.code == 403
        raise NotFound, response.body if response.code == 404
        raise FailRequestError, response.code unless response.success?

        response
      end

      def process_response(response)
        handled_resp = handle_response response
        handled_resp.parsed_response
      rescue JSON::ParserError => e
        raise ParseResponseError, e.message
      end

      def process_response_with_uri(response)
        handled_resp = handle_response response
        parsed_handled_resp = process_response handled_resp

        {
          response: parsed_handled_resp,
          uri: handled_resp.request.last_uri.to_s
        }
      end

      def add_auth_header(options = {})
        return options unless @token
        update_token if token_expire?

        auth_headers = { 'Authorization': "Bearer #{@token}" }
        if options[:headers]
          options[:headers].merge!(
            auth_headers
          )
        else
          options[:headers] = auth_headers
        end
        options
      end

      private

      def oauth_header
        {
          body: {
            client_id: self.class.default_options[:client_id],
            client_secret: self.class.default_options[:client_secret],
            redirect_uri: self.class.default_options[:redirect_uri]
          }.to_json,
          headers: {
            'Content-Type' => 'application/json',
            'Accept' => 'application/json'
          }
        }
      end

      def token_expire?
        @expires_in < Time.now.to_i + 10
      end

      def update_token
        options = oauth_header[:body].merge(
          refresh_token: @refresh_token,
          grant_type: 'refresh_token'
        )

        response = process_response(
          self.class.post('/oauth2/access_token', options)
        )

        @token = response['access_token']
        @refresh_token = response['refresh_token']
        @expires_in = Time.now.to_i + response['expires_in']

        write_token
      end

      def write_token
        return unless self.class.default_options[:token_file]

        file = File.new(self.class.default_options[:token_file], 'w')
        json = {
          'access_token': @token,
          'expires_in': @expires_in,
          'refresh_token': @refresh_token
        }
        file.puts(json.to_json)
        file.close
      end
    end

    class UnauthorizedRequest < Error; end
    class Forbidden < Error; end
    class NotFound < Error; end
    class FailRequestError < Error; end
    class ParseResponseError < Error; end
  end
end
