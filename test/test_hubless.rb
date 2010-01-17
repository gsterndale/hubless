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

  def test_install_gems
    local_gems = [
        mock(:install_cmd => 'foo', :github? => true, :gemcutter? => true),
        mock(:install_cmd => 'bar', :github? => true, :gemcutter? => true),
        mock(:install_cmd => 'abc', :github? => true, :gemcutter? => true),
        mock(:github? => true, :gemcutter? => false),
        mock(:github? => false)
      ]
    Hubless::GemDescription.expects(:local_gems).once.returns(local_gems)
    @io.expects(:puts).with{|s| s =~ /Installing gems:/ }
    @io.expects(:puts).once.with{|s| s =~ /foo/ }
    @io.expects(:puts).once.with{|s| s =~ /bar/ }
    @io.expects(:puts).once.with{|s| s =~ /abc/ }
    Kernel.expects(:system).once.with{|s| s =~ /foo/ }.returns(true)
    Kernel.expects(:system).once.with{|s| s =~ /bar/ }.returns(true)
    Kernel.expects(:system).once.with{|s| s =~ /abc/ }.returns(true)
    hubless = Hubless.new
    hubless.install_gems
    
    local_gems = [
        mock(:install_cmd => 'foo', :github? => true, :gemcutter? => true)
      ]
    Hubless::GemDescription.expects(:local_gems).once.returns(local_gems)
    @io.expects(:puts).with{|s| s =~ /Installing gems:/ }
    @io.expects(:puts).once.with{|s| s =~ /foo/ }
    Kernel.expects(:system).once.with{|s| s =~ /foo/ }.returns(false)
    hubless = Hubless.new
    assert_raise(Hubless::GemInstallError) { hubless.install_gems }
  end

end
