require 'rubygems'
require 'net/http'

class Hubless
ServiceError = Class.new(RuntimeError)

class GemDescription

  attr_reader :name
  attr_accessor :version

  # GemDescriptions of all gems installed locally
  def self.local_gems
    @@local_gems ||= Gem.cache.map {|g| new(g.first) }.sort!{|x,y| y.name <=> x.name }
  end

  # New GemDescription from a one-liner or options Hash
  # Hubless::GemDescription.new('my-awesome_gem-3.4.5')
  # Hubless::GemDescription.new(:name => 'my-awesome_gem', :version => '3.4.5')
  def initialize(*args)
    case args.first
    when String
      self.attributes_from_one_liner(args.first)
    when Hash
      self.name    = args.first[:name]
      self.version = args.first[:version]
    end
  end

  # Assign gem description name and clear any cached values
  def name=(str)
    self.clear
    @name = str
  end

  # Does a repo exist on GitHub that matches this gem
  def github?
    if @is_github.nil?
      @is_github = (self.github_like? && self.github_repo_exist?)
    else
      @is_github
    end
  end

  # Full name of this gem including GitHub username
  def github_name
    self.name if self.github_user_name
  end
  
  def github_like?
    self.github_user_name && self.github_repo_name
  end

  # Does a gem exist on Gemcutter that matches this gem
  def gemcutter?
    if @is_gemcutter.nil?
      @is_gemcutter = self.gemcutter_gem_exist?
    else
      @is_gemcutter
    end
  end

  # Likely name of this gem on Gemcutter (without the GitHub username)
  def gemcutter_name
    self.github? ? self.github_repo_name : self.name
  end

  # Command to install gem from Gemcutter
  def install_cmd
    cmd = ["gem install"]
    cmd << self.gemcutter_name
    cmd << "-v #{self.version}" if self.version
    cmd.join(' ')
  end

  # Command to uninstall gem
  def uninstall_cmd
    cmd = ["gem uninstall"]
    cmd << self.name
    cmd << "-v #{self.version}" if self.version
    cmd.join(' ')
  end

protected

  def clear
    @is_gemcutter = @is_github = nil
  end

  def github_user_name
    if self.name =~ /^([^-]*)-.*$/
      $1
    end
  end
  
  def github_repo_name
    if self.name =~ /^[^-]*-(.*)$/
      $1
    end
  end

  def github_uri
    URI.parse("http://github.com/api/v2/yaml/repos/show/#{self.github_user_name}/#{self.github_repo_name}")
  end

  def github_repo_exist?
    response = Net::HTTP.get(self.github_uri)
    case
    when response =~ /error: repository not found/
      false
    when response =~ /error: too many requests/
      raise ServiceError
    else
      true
    end
  end

  def gemcutter_uri
    URI.parse("http://gemcutter.org/api/v1/gems/#{self.name}.json")
  end

  def gemcutter_gem_exist?
    response = Net::HTTP.get(self.gemcutter_uri)
    case
    when response =~ /This rubygem could not be found./
      false
    when response =~ /error: too many requests/
      raise ServiceError
    else
      true
    end
  end

  def attributes_from_one_liner(one_liner)
    if one_liner =~ /^(.*)-([\d\.]+)$/
      self.name = $1
      self.version = $2
    end
  end

end
end