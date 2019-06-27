require "cloudcms/version"
# require 'driver'
require 'platform'

# ENV['OAUTH_DEBUG'] = 'true'

module Cloudcms
    class Error < StandardError; end

    # Driver
    class Cloudcms
        attr_accessor :config
        attr_accessor :connection
        attr_accessor :platform

        def initialize
        end

        def connect(path="./gitana.json")
            # @driver = Driver.new()
            # read gitana connection info
            @config = JSON.parse(File.read(path))
            @config['requestedScope'] = 'api'
            if (!@config['baseURL'])
                @config['baseURL'] = 'https://api1.cloudcms.com'
            end
            
            begin
                # get oAuth2 token
                client = OAuth2::Client.new(
                    @config['clientKey'],
                    @config['clientSecret'],
                    :site => @config['baseURL'],
                    :token_url => '/oauth/token'
                )

                client.auth_code.authorize_url()
                @connection = client.password.get_token(@config['username'], @config['password'])
                puts 'Authentication token: ' + @connection.token + ' expires in: ' + @connection.expires_in.to_s + ' seconds'
            
                response = @connection.request :get, @config['baseURL'] + "/auth/info"
                puts 'Connected to tenant: ' + response.parsed['tenantTitle'] + ' as user: ' + response.parsed['user']['name']
            
                # read platform
                response = @connection.request :get, @config['baseURL'] + "/?metadata=true&full=true"
                platform = response.parsed
                # puts 'platform: ' + JSON.pretty_generate(platform)

                platform.driver = self
            rescue
                "Error connecting"
            end
        end
    end
end