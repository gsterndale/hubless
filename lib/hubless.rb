require File.dirname(__FILE__) + '/gem_description'

class Hubless
  @@io = $stdout
  @@timeout = 1
  
  def self.io=(io)
    @@io = io
  end

  def self.timeout=(t)
    @@timeout = t
  end

  def gem_breakdown
    github_like_count = self.gems.select{|g| g.github_like? }.length
    @@io.puts "\nFound #{gems.length} local gems. Of those, #{github_like_count} look like GitHub gems."
  end

  def github_repos
    @@io.puts("\nSearching GitHub for matching repositories...")
    github_gem_count = 0
    self.gems.each do |g|
      if g.github_like?
        github_gem_count += 1 if is_on_github = g.github?
        @@io.print(is_on_github ? 'Y' : 'N')
        @@io.flush
        sleep @@timeout
      end
    end
    @@io.puts("\nFound #{github_gem_count} repositories on GitHub.")
  end

  def gemcutter_gems
    @@io.puts("\nSearching for matching gems on Gemcutter...")
    gemcutter_gem_count = 0
    self.gems.each do |g|
      if g.github?
        gemcutter_gem_count += 1 if is_on_gemcutter = g.gemcutter?
        @@io.print(is_on_gemcutter ? 'Y' : 'N')
        @@io.flush
        sleep @@timeout
      end
    end
    @@io.puts("\nFound #{gemcutter_gem_count} gems on Gemcutter.")
  end

  def uninstall_instructions
    @@io.puts("\nTo uninstall these GitHub gems run:")
    self.gems.each {|g| @@io.puts(g.uninstall_cmd) if g.github? && g.gemcutter? }
  end

  def install_instructions
    @@io.puts("\nTo reinstall these gems from Gemcutter run:")
    self.gems.each {|g| @@io.puts(g.install_cmd) if g.github? && g.gemcutter? }
  end

  # def self.reinstall_gems
  #   self.gems.each do |g|
  #     if g.github? && g.gemcutter?
  #       @@io.puts %x(#{g.uninstall_cmd})
  #       @@io.puts %x(#{g.install_cmd})
  #     end
  #   end
  # end

protected

  def gems
    @gems ||= Hubless::GemDescription.local_gems
  end

end

# Hubless.local_gems_on_github.each{|g| puts g.inspect }