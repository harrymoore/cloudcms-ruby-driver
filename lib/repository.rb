module Cloudcms
    class Repository
        attr_accessor :driver
        attr_accessor :data
        attr_accessor :platform
        attr_accessor :project
        attr_accessor :branchesByTitle
        attr_accessor :branchesById
        attr_accessor :branches
        attr_accessor :master

        def initialize(driver, platform, project, data)
            @driver = driver
            @data = data
            @platform = platform
            @project = project
            
            # list branches
            response = @driver.connection.request :get, @driver.config['baseURL'] + "/repositories/#{@data['_doc']}/branches"
            branchIds = response.parsed
            # puts 'branchIds: ' + JSON.pretty_generate(branchIds)
            
            # read all the branches
            @branchesByTitle = Hash.new
            @branchesById = Hash.new
            @branches= Array.new
            i = 0
            while i < branchIds['rows'].length
                response = @driver.connection.request :get, @driver.config['baseURL'] + "/repositories/#{@data['_doc']}/branches/#{branchIds['rows'][i]['_doc']}"
                branch = Branch.new(@driver, self, @project, @repository, response.parsed)
                @branchesByTitle[branch.data['title']] = branch
                @branchesById[branch.data['_doc']] = branch
                @branches.push(branch)
                i += 1
            end
            @master = branchesByTitle['master']

            return self
        end

        def list_branches()
            branches= Array.new
            response = @driver.request :get, @driver.config['baseURL'] + "/repository/#{@data['_doc']}/branches?metadata=true&full=true"
            while i < response.parsed['rows'].length
                branch = Branch.new(@driver, self, @project, @repository, response.parsed['rows'][i])
                branches.push(branch)
                i += 1
            end
            return branches
        end

        def read_branch()
            response = @driver.request :get, @driver.config['baseURL'] + "/repository/#{@data['_doc']}?metadata=true&full=true"
            @platform = Platform.new(self, response.parsed)
        end
    end
end