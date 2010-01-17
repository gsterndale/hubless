require 'helper'

class TestHubless < Test::Unit::TestCase

  def setup
    Hubless.io = mock_io
    Hubless.timeout = 0
  end

  def mock_io
    @io = mock
    @io.stubs(:print).returns(nil)
    @io.stubs(:flush).returns(nil)
    @io.stubs(:puts).returns(nil)
    @io
  end

  def test_local_gem_breakdown
    local_gems = [
        mock(:github_like? => true),
        mock(:github_like? => true),
        mock(:github_like? => false)
      ]
    gem_count = 3
    github_like_count = 2
    Hubless::GemDescription.expects(:local_gems).once.returns(local_gems)
    @io.expects(:puts).
        with{|s| s =~ /Found #{gem_count} local gems. Of those, #{github_like_count} look like GitHub gems./ }
    hubless = Hubless.new
    hubless.gem_breakdown
  end

  def test_github_repos
    local_gems = [
        mock(:github_like? => true,  :github? => true),
        mock(:github_like? => true,  :github? => false),
        mock(:github_like? => false)
      ]
    github_count = 1
    Hubless::GemDescription.expects(:local_gems).once.returns(local_gems)
    @io.expects(:puts).with{|s| s =~ /Searching GitHub for matching repositories.../ }
    @io.expects(:print).once.with('Y')
    @io.expects(:print).once.with('N')
    @io.expects(:flush).times(2)
    @io.expects(:puts).with{|s| s =~ /Found #{github_count} repositories on GitHub./ }
    hubless = Hubless.new
    hubless.github_repos
  end

  def test_gemcutter_gems
    local_gems = [
        mock(:github? => true, :gemcutter? => true),
        mock(:github? => true, :gemcutter? => false),
        mock(:github? => false)
      ]
    gemcutter_count = 1
    Hubless::GemDescription.expects(:local_gems).once.returns(local_gems)
    @io.expects(:puts).with{|s| s =~ /Searching for matching gems on Gemcutter.../ }
    @io.expects(:print).once.with('Y')
    @io.expects(:print).once.with('N')
    @io.expects(:flush).times(2)
    @io.expects(:puts).with{|s| s =~ /Found #{gemcutter_count} gems on Gemcutter./ }
    hubless = Hubless.new
    hubless.gemcutter_gems
  end

  def test_uninstall_instructions
    local_gems = [
        mock(:uninstall_cmd => 'foo', :github? => true, :gemcutter? => true),
        mock(:uninstall_cmd => 'bar', :github? => true, :gemcutter? => true),
        mock(:uninstall_cmd => 'abc', :github? => true, :gemcutter? => true),
        mock(:github? => true, :gemcutter? => false),
        mock(:github? => false)
      ]
    Hubless::GemDescription.expects(:local_gems).once.returns(local_gems)
    @io.expects(:puts).with{|s| s =~ /To uninstall these GitHub gems run:/ }
    @io.expects(:puts).once.with{|s| s =~ /foo/ }
    @io.expects(:puts).once.with{|s| s =~ /bar/ }
    @io.expects(:puts).once.with{|s| s =~ /abc/ }
    hubless = Hubless.new
    hubless.uninstall_instructions
  end

  def test_install_instructions
    local_gems = [
        mock(:install_cmd => 'foo', :github? => true, :gemcutter? => true),
        mock(:install_cmd => 'bar', :github? => true, :gemcutter? => true),
        mock(:install_cmd => 'abc', :github? => true, :gemcutter? => true),
        mock(:github? => true, :gemcutter? => false),
        mock(:github? => false)
      ]
    Hubless::GemDescription.expects(:local_gems).once.returns(local_gems)
    @io.expects(:puts).with{|s| s =~ /To reinstall these gems from Gemcutter run:/ }
    @io.expects(:puts).once.with{|s| s =~ /foo/ }
    @io.expects(:puts).once.with{|s| s =~ /bar/ }
    @io.expects(:puts).once.with{|s| s =~ /abc/ }
    hubless = Hubless.new
    hubless.install_instructions
  end


  # def setup
  #   @gems = [
  #       [ 'my-github_and_gemcutter_gem-0.1.2', mock ],
  #       [ 'my-github_only_gem-1.2.3', mock ],
  #       [ 'my-github_look_a_like_on_gemcutter_gem-2.3.4', mock ],
  #       [ 'my_non_github_gem-3.4.5', mock ]
  #     ]
  #   Gem.stubs(:cache).returns(@gems)
  # end
  # 
  # def teardown
  #   Hubless.clear
  # end
  # 
  # def test_local_gems
  #   local_gems = Hubless.local_gems
  #   assert local_gems.detect{|gem_description| gem_description.name == 'my-github_and_gemcutter_gem' }
  #   assert local_gems.detect{|gem_description| gem_description.name == 'my-github_only_gem' }
  #   assert local_gems.detect{|gem_description| gem_description.name == 'my-github_look_a_like_on_gemcutter_gem' }
  #   assert local_gems.detect{|gem_description| gem_description.name == 'my_non_github_gem' }
  #   assert_equal @gems.length, local_gems.length
  # end
  # 
  # def test_local_github_like_gems
  #   local_github_like_gems = Hubless.local_github_like_gems
  #   assert local_github_like_gems.detect{|gem_description| gem_description.name == 'my-github_and_gemcutter_gem' }
  #   assert local_github_like_gems.detect{|gem_description| gem_description.name == 'my-github_only_gem' }
  #   assert local_github_like_gems.detect{|gem_description| gem_description.name == 'my-github_look_a_like_on_gemcutter_gem' }
  #   assert ! local_github_like_gems.detect{|gem_description| gem_description.name == 'my_non_github_gem' }
  # end
  # 
  # def test_local_gems_on_github
  #   Net::HTTP.expects(:get).times(3).
  #     returns("--- \nrepository: \n  :description: Description here\n  :forks: 0\n  :url: http://github.com/some_user/some_repo\n  :fork: false\n  :open_issues: 0\n  :watchers: 1\n  :private: false\n  :name: some_repo\n  :owner: some_user\n").
  #     returns("--- \nrepository: \n  :description: Description here\n  :forks: 0\n  :url: http://github.com/some_user/some_repo\n  :fork: false\n  :open_issues: 0\n  :watchers: 1\n  :private: false\n  :name: some_repo\n  :owner: some_user\n").
  #     returns("--- \nerror: \n- error: repository not found\n")
  #   local_gems_on_github = Hubless.local_gems_on_github
  #   assert local_gems_on_github.detect{|gem_description| gem_description.name == 'my-github_and_gemcutter_gem' }
  #   assert local_gems_on_github.detect{|gem_description| gem_description.name == 'my-github_only_gem' }
  #   assert ! local_gems_on_github.detect{|gem_description| gem_description.name == 'my-github_look_a_like_on_gemcutter_gem' }
  #   assert ! local_gems_on_github.detect{|gem_description| gem_description.name == 'my_non_github_gem' }
  # end
  # 
  # def test_local_gems_on_github_with_github_error
  #   Net::HTTP.expects(:get).times(2).
  #     returns("--- \nrepository: \n  :description: Description here\n  :forks: 0\n  :url: http://github.com/some_user/some_repo\n  :fork: false\n  :open_issues: 0\n  :watchers: 1\n  :private: false\n  :name: some_repo\n  :owner: some_user\n").
  #     returns("--- \nerror: \n- error: too many requests\n")
  #   assert_raise(ServiceError) { Hubless.local_gems_on_github }
  # end
  # 
  # def test_local_gems_on_github_and_gemcutter
  #   Net::HTTP.expects(:get).times(5).
  #     returns("--- \nrepository: \n  :description: Description here\n  :forks: 0\n  :url: http://github.com/some_user/some_repo\n  :fork: false\n  :open_issues: 0\n  :watchers: 1\n  :private: false\n  :name: some_repo\n  :owner: some_user\n").
  #     returns("--- \nrepository: \n  :description: Description here\n  :forks: 0\n  :url: http://github.com/some_user/some_repo\n  :fork: false\n  :open_issues: 0\n  :watchers: 1\n  :private: false\n  :name: some_repo\n  :owner: some_user\n").
  #     returns("--- \nerror: \n- error: repository not found\n").
  #     returns(%Q{{"version_downloads":137674,"info":"    Rails is a framework for building web-application using CGI, FCGI, mod_ruby, or WEBrick\n    on top of either MySQL, PostgreSQL, SQLite, DB2, SQL Server, or Oracle with eRuby- or Builder-based templates.\n","project_uri":"http://gemcutter.org/gems/rails","name":"rails","version":"2.3.5","gem_uri":"http://gemcutter.org/gems/rails-2.3.5.gem","downloads":218523,"authors":"David Heinemeier Hansson"}}).
  #     returns("This rubygem could not be found.")
  #   local_gems_on_github_and_gemcutter = Hubless.local_gems_on_github_and_gemcutter
  #   assert local_gems_on_github_and_gemcutter.detect{|gem_description| gem_description.name == 'my-github_and_gemcutter_gem' }
  #   assert ! local_gems_on_github_and_gemcutter.detect{|gem_description| gem_description.name == 'my-github_only_gem' }
  #   assert ! local_gems_on_github_and_gemcutter.detect{|gem_description| gem_description.name == 'my-github_look_a_like_on_gemcutter_gem' }
  #   assert ! local_gems_on_github_and_gemcutter.detect{|gem_description| gem_description.name == 'my_non_github_gem' }
  # end
  # 
  # def test_clear
  #   Net::HTTP.expects(:get).times(5).
  #     returns("--- \nrepository: \n  :description: Description here\n  :forks: 0\n  :url: http://github.com/some_user/some_repo\n  :fork: false\n  :open_issues: 0\n  :watchers: 1\n  :private: false\n  :name: some_repo\n  :owner: some_user\n").
  #     returns("--- \nrepository: \n  :description: Description here\n  :forks: 0\n  :url: http://github.com/some_user/some_repo\n  :fork: false\n  :open_issues: 0\n  :watchers: 1\n  :private: false\n  :name: some_repo\n  :owner: some_user\n").
  #     returns("--- \nerror: \n- error: repository not found\n").
  #     returns(%Q{{"version_downloads":137674,"info":"    Rails is a framework for building web-application using CGI, FCGI, mod_ruby, or WEBrick\n    on top of either MySQL, PostgreSQL, SQLite, DB2, SQL Server, or Oracle with eRuby- or Builder-based templates.\n","project_uri":"http://gemcutter.org/gems/rails","name":"rails","version":"2.3.5","gem_uri":"http://gemcutter.org/gems/rails-2.3.5.gem","downloads":218523,"authors":"David Heinemeier Hansson"}}).
  #     returns("This rubygem could not be found.")
  # 
  #   Hubless.local_gems_on_github_and_gemcutter
  # 
  #   Net::HTTP.expects(:get).times(0)
  # 
  #   Hubless.local_gems_on_github_and_gemcutter
  # 
  #   Hubless.clear
  # 
  #   Net::HTTP.expects(:get).times(5).
  #     returns("--- \nrepository: \n  :description: Description here\n  :forks: 0\n  :url: http://github.com/some_user/some_repo\n  :fork: false\n  :open_issues: 0\n  :watchers: 1\n  :private: false\n  :name: some_repo\n  :owner: some_user\n").
  #     returns("--- \nrepository: \n  :description: Description here\n  :forks: 0\n  :url: http://github.com/some_user/some_repo\n  :fork: false\n  :open_issues: 0\n  :watchers: 1\n  :private: false\n  :name: some_repo\n  :owner: some_user\n").
  #     returns("--- \nerror: \n- error: repository not found\n").
  #     returns(%Q{{"version_downloads":137674,"info":"    Rails is a framework for building web-application using CGI, FCGI, mod_ruby, or WEBrick\n    on top of either MySQL, PostgreSQL, SQLite, DB2, SQL Server, or Oracle with eRuby- or Builder-based templates.\n","project_uri":"http://gemcutter.org/gems/rails","name":"rails","version":"2.3.5","gem_uri":"http://gemcutter.org/gems/rails-2.3.5.gem","downloads":218523,"authors":"David Heinemeier Hansson"}}).
  #     returns("This rubygem could not be found.")
  # 
  #   Hubless.local_gems_on_github_and_gemcutter
  # end
def test_nothin
  assert true
end


end
