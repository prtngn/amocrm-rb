module AmoCRMClient
  module Http
    class Error < StandardError; end
    # Your code goes here...
  end
end

require 'httparty'
require 'amocrm_client/http/base'
require 'amocrm_client/http/client'
require 'amocrm_client/http/contacts'
