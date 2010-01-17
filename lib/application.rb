require File.dirname(__FILE__) + '/hubless'

class Hubless
  class Application
    
    def self.run(*args)
      hubless = Hubless.new
      hubless.gem_breakdown
      hubless.github_repos
      hubless.gemcutter_gems
      hubless.uninstall_instructions
      hubless.install_instructions
      return 0
    end
    
  end
end