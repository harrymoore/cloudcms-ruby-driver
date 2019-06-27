require 'oauth2'
require 'json'

# ENV['OAUTH_DEBUG'] = 'true'

module Cloudcms
    class Platform
        attr_accessor :driver
        attr_accessor :data
        attr_accessor :project
        attr_accessor :repository
        attr_accessor :brachesByTitle
        attr_accessor :brachesById
        attr_accessor :braches
        attr_accessor :master

        def initialize(driver, data)
            @driver = driver
            @data = data
            # puts 'platform data: ' + JSON.pretty_generate(@data)

            # preload:

            # read application
            response = @driver.connection.request :get, @driver.config['baseURL'] + "/applications/" + @driver.config['application'] + "?metadata=true&full=true"
            application = response.parsed
            # puts 'application: ' + JSON.pretty_generate(application)

            # find stack by application id
            response = @driver.connection.request :get, @driver.config['baseURL'] + "/stacks/find/application/" + @driver.config['application'] + "?metadata=true&full=true"
            stack = response.parsed
            # puts 'stack: ' + JSON.pretty_generate(stack)

            # read stack's datastores
            response = @driver.connection.request :get, @driver.config['baseURL'] + "/stacks/" + response.parsed['_doc'] + "/datastores"
            datastores = response.parsed

            projectId = ""
            contentRepositoryId = ""
            domainId = ""
            application = ""
            i = 0
            while i < datastores['rows'].length
                if (datastores['rows'][i]['_doc'] == @driver.config['application'])
                    # this is the application datastore
                    projectId = datastores['rows'][i]['projectId']
                    # puts 'rows[i]: ' + JSON.pretty_generate(datastores['rows'][i])
                end

                if (datastores['rows'][i]['_doc'] == 'content')
                    contentRepositoryId = datastores['rows'][i]['datastoreId']
                    # puts 'rows[i]: ' + JSON.pretty_generate(datastores['rows'][i])
                end

                if (datastores['rows'][i]['_doc'] == 'principals')
                    domainId = datastores['rows'][i]['defaultDirectoryId']
                end

                i += 1
            end
            
            # read project
            response = @driver.connection.request :get, @driver.config['baseURL'] + "/projects/" + projectId
            @project = response.parsed
            # puts 'project: ' + JSON.pretty_generate(project)
            
            # read 'content' repository for the project
            response = @driver.connection.request :get, @driver.config['baseURL'] + "/repositories/" + contentRepositoryId
            @repository = response.parsed
            # puts 'repository: ' + JSON.pretty_generate(repository)
            
            # list branches
            response = @driver.connection.request :get, @driver.config['baseURL'] + "/repositories/" + contentRepositoryId + "/branches"
            branchIds = response.parsed
            # puts 'branchIds: ' + JSON.pretty_generate(branchIds)
            
            # read all the branches
            @brachesByTitle = Hash.new
            @brachesById = Hash.new
            @braches= Array.new
            i = 0
            while i < branchIds['rows'].length
                response = @driver.connection.request :get, @driver.config['baseURL'] + "/repositories/" + contentRepositoryId + "/branches/" + branchIds['rows'][i]['_doc']
                branch = response.parsed
                @brachesByTitle[branch['title']] = branch
                @brachesById[branch['_doc']] = branch
                @braches.push(branch)
                i += 1
                # puts 'branch: ' + JSON.pretty_generate(branch)
            end
            @master = brachesByTitle['master']
            # puts 'brachesByTitle: ' + JSON.pretty_generate(brachesByTitle)
            # puts 'brachesById: ' + JSON.pretty_generate(brachesById)
            # puts 'braches: ' + JSON.pretty_generate(braches)

            return self
        end

        def read_repository(id)
            response = @driver.request :get, @driver.config['baseURL'] + "/repository/#{id}?metadata=true&full=true"
            @platform = Platform.new(self, response.parsed)
        end
    end
end
