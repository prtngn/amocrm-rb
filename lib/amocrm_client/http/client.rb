module AmoCRMClient
  module Http
    class Client < Base
      def get_fields(options = {})
        add_auth_header(options)
        process_response(
          self.class.get('/api/v4/contacts/custom_fields', options)
        )&.dig('_embedded', 'custom_fields')
      end

      def get(options = {})
        options = { query: options }
        add_auth_header(options)
        process_response(
          self.class.get('/api/v4/contacts', options)
        )&.dig('_embedded', 'contacts')
      end

      def add(options = [])
        return if options.empty?

        options = { body: options.to_json }
        add_auth_header(options)
        process_response(
          self.class.post('/api/v4/contacts', options)
        )
      end

      def auth
        file = File.new(self.class.default_options[:token_file], 'r')
        json = JSON.parse(file.readlines[0])
        file.close
        @token = json['access_token']
        @expires_in = json['expires_in']
        @refresh_token = json['refresh_token']
        update_token if token_expire?
        true
      end

      def get_access_token_by_code(options = {})
        options = oauth_header[:body].merge(
          code: options[:code],
          grant_type: 'authorization_code'
        )

        response = process_response(
          self.class.post('/oauth2/access_token', options)
        )

        @token = response['access_token']
        @expires_in = Time.now.to_i + (response['expires_in'] - 120)
        @refresh_token = response['refresh_token']
        write_token
      end
    end
  end
end
