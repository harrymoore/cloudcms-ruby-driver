require 'oauth2'
require 'json'

# ENV['OAUTH_DEBUG'] = 'true'

module Cloudcms
    @config
    @connection

    class Platform
        attr_accessor :driver
        attr_accessor :data

        def initialize(driver, data)
            @driver = driver
            @data = data
        end

        def connect(path="./gitana.json")
        end
    end
end
