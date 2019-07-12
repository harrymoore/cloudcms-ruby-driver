require 'oauth2'
require 'json'
require 'cloudcms/branch'

# ENV['OAUTH_DEBUG'] = 'true'

module Cloudcms
    class Platform
        attr_accessor :driver
        attr_accessor :data
        attr_accessor :project
        attr_accessor :repository
        attr_accessor :branchesByTitle
        attr_accessor :branchesById
        attr_accessor :branches
        attr_accessor :master
        attr_accessor :stack
        attr_accessor :datastores
        attr_accessor :application

        def initialize(driver, data)
            @driver = driver
            @data = data
            # puts 'platform data: ' + JSON.pretty_generate(@data)

            # preload:

            # read application
            response = @driver.connection.request :get, @driver.config['baseURL'] + "/applications/" + @driver.config['application'] + "?metadata=true&full=true"
            @application = response.parsed
            # puts 'application: ' + JSON.pretty_generate(@application)

            # find stack by application id
            response = @driver.connection.request :get, @driver.config['baseURL'] + "/stacks/find/application/" + @application['_doc'] + "?metadata=true&full=true"
            @stack = response.parsed
            # puts 'stack: ' + JSON.pretty_generate(@stack)

            # read stack's datastores
            response = @driver.connection.request :get, @driver.config['baseURL'] + "/stacks/" + stack['_doc'] + "/datastores"
            @datastores = response.parsed

            projectId = ""
            contentRepositoryId = ""
            domainId = ""
            application = ""
            i = 0
            while i < @datastores['rows'].length
                if (@datastores['rows'][i]['_doc'] == @application['_doc'])
                    # this is the application datastore
                    # get the project id
                    projectId = @datastores['rows'][i]['projectId']
                    # puts 'rows[i]: ' + JSON.pretty_generate(@datastores['rows'][i])
                end

                if (@datastores['rows'][i]['_doc'] == 'content')
                    contentRepositoryId = @datastores['rows'][i]['datastoreId']
                    # puts 'rows[i]: ' + JSON.pretty_generate(@datastores['rows'][i])
                end

                if (@datastores['rows'][i]['_doc'] == 'principals')
                    #  this is the projects domain
                    domainId = @datastores['rows'][i]['defaultDirectoryId']
                end

                i += 1
            end
            
            # read project
            response = @driver.connection.request :get, @driver.config['baseURL'] + "/projects/" + projectId
            @project = response.parsed
            # puts 'project: ' + JSON.pretty_generate(project)
            
            # read 'content' repository for the project containing this application
            response = @driver.connection.request :get, @driver.config['baseURL'] + "/repositories/" + contentRepositoryId
            @repository = Repository.new(@driver, self, @project, response.parsed)
            puts 'repository: ' + JSON.pretty_generate(repository)

            return self
        end

        def list_repositories()
            repositories = Array.new
            response = @driver.connection.request :get, @driver.config['baseURL'] + "/repositories?metadata=true&full=true"
            i = 0
            while i < response.parsed['rows'].length
                repository = Repository.new(@driver, self, @project, response.parsed['rows'][i])
                repositories.push(repository)
                i += 1
            end
            return repositories
        end

        def read_repository(id)
            response = @driver.connection.request :get, @driver.config['baseURL'] + "/repositories/#{id}?metadata=true&full=true"
            return Repository.new(@driver, self, @project, response.parsed)
        end

    end
end
