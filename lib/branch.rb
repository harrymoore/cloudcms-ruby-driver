module Cloudcms
    class Branch
        attr_accessor :driver
        attr_accessor :data
        attr_accessor :platform
        attr_accessor :project
        attr_accessor :repository
        attr_accessor :branchesByTitle
        attr_accessor :branchesById
        attr_accessor :branches
        attr_accessor :master

        def initialize(driver, platform, project, repository, data)
            @driver = driver
            @data = data
            @platform = platform
            @project = project
            @repository = repository
            
            return self
        end

        def read_repository(id)
            response = @driver.request :get, @driver.config['baseURL'] + "/repository/#{id}?metadata=true&full=true"
            @platform = Platform.new(self, response.parsed)
        end
    end
end
