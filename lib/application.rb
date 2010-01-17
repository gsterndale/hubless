require File.dirname(__FILE__) + '/hubless'

class Hubless
  class Application
    
    def self.run(*args)
      if help_option?(args)
        display_help
      else
        hubless = Hubless.new
        hubless.gem_breakdown
        hubless.github_repos
        hubless.gemcutter_gems
        hubless.uninstall_instructions
        if install_option?(args)
          hubless.install_gems
        else
          hubless.install_instructions
        end
      end
      return 0
    end

  protected
    
    def self.display_help
      $stdout.puts "Search your local gem repository for gems installed from GitHub that have since moved to Gemcutter"
      $stdout.puts "Usage: hubless [-i|-h] "
      $stdout.puts "\t-i, --install\tinstall GitHub gems that are on Gemcutter (consider running with sudo)"
      $stdout.puts "\t-h, --help\tdisplay this help and exit"
    end

    def self.install_option?(args)
      args.include?('-i') || args.include?('--install') 
    end

    def self.help_option?(args)
      args.include?('-h') || args.include?('--help') 
    end

  end
end