module Cloudcms
    class Node
        attr_accessor :driver
        attr_accessor :data
        attr_accessor :platform
        attr_accessor :project
        attr_accessor :repository
        attr_accessor :branche

        def initialize(driver, platform, project, repository, branch, data)
            @driver = driver
            @data = data
            @platform = platform
            @project = project
            @repository = repository
            @branch = branch
            
            return self
        end

        def update()
            # TODO
        end

        def delete()
            # TODO
        end

        def update()
            # TODO
        end
    end
end
