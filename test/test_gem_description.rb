require 'helper'

class TestGemDescription < Test::Unit::TestCase

  def test_local_gems
    gems = [
        [ 'my-github_and_gemcutter_gem-0.1.2', mock ],
        [ 'my-github_only_gem-1.2.3', mock ],
        [ 'my-github_look_a_like_on_gemcutter_gem-2.3.4', mock ],
        [ 'my_non_github_gem-3.4.5', mock ]
      ]
    Gem.expects(:cache).once.returns(gems)
    local_gems = Hubless::GemDescription.local_gems
    assert local_gems.all?{|gem_description| gem_description.is_a?(Hubless::GemDescription) }
    assert local_gems.detect{|gem_description| gem_description.name == 'my-github_and_gemcutter_gem' }
    assert local_gems.detect{|gem_description| gem_description.name == 'my-github_only_gem' }
    assert local_gems.detect{|gem_description| gem_description.name == 'my-github_look_a_like_on_gemcutter_gem' }
    assert local_gems.detect{|gem_description| gem_description.name == 'my_non_github_gem' }
    assert_equal gems.length, local_gems.length
    # test number of expected calls to Gem.cache are not exceeded
    Hubless::GemDescription.local_gems
  end

  def test_new_with_one_liner
    one_liner = 'my-github_and_gemcutter_gem-0.1.2'
    gem_description = Hubless::GemDescription.new(one_liner)
    assert_equal 'my-github_and_gemcutter_gem', gem_description.name
    assert_equal '0.1.2', gem_description.version
  end

  def test_new_with_attr_hash
    name = 'my-github_and_gemcutter_gem'
    version = '0.1.2'
    gem_description = Hubless::GemDescription.new(:name => name, :version => version)
    assert_equal name, gem_description.name
    assert_equal version, gem_description.version
  end

  def test_name_attr
    name = 'my-github_and_gemcutter_gem'
    gem_description = Hubless::GemDescription.new
    gem_description.name = name
    assert_equal name, gem_description.name
  end

  def test_github_name
    user = 'my'
    repo = 'github_and_gemcutter_gem'
    name = "#{user}-#{repo}"
    gem_description = Hubless::GemDescription.new(:name => name)
    assert_equal name, gem_description.github_name

    name = 'non_github_gem'
    gem_description = Hubless::GemDescription.new(:name => name)
    assert_nil gem_description.github_name
  end

  def test_github_like?
    user = 'my'
    repo = 'github_and_gemcutter_gem'
    name = "#{user}-#{repo}"
    gem_description = Hubless::GemDescription.new(:name => name)
    assert gem_description.github_like?

    name = 'non_github_gem'
    gem_description = Hubless::GemDescription.new(:name => name)
    assert ! gem_description.github_like?
  end
  
  def test_gemcutter_name
    user = 'my'
    repo = 'github_and_gemcutter_gem'
    name = "#{user}-#{repo}"
    gem_description = Hubless::GemDescription.new(:name => name)
    expect_github_request(/github.*\/#{repo}/, true)
    assert_equal repo, gem_description.gemcutter_name

    user = 'my'
    repo = 'github_look_a_like_gem'
    name = "#{user}-#{repo}"
    gem_description = Hubless::GemDescription.new(:name => name)
    expect_github_request(/github.*\/#{repo}/, false)
    assert_equal name, gem_description.gemcutter_name

    name = 'non_github_gem'
    gem_description = Hubless::GemDescription.new(:name => name)
    expect_no_request
    assert_equal name, gem_description.gemcutter_name
  end

  def test_github?
    user = 'my'
    repo = 'github_gem'
    name = "#{user}-#{repo}"
    github_gem = Hubless::GemDescription.new(:name => name)
    expect_github_request(/github.*\/#{repo}/, true)
    assert github_gem.github?

    user = 'my'
    repo = 'github_look_a_like_gem'
    name = "#{user}-#{repo}"
    github_look_a_like_gem = Hubless::GemDescription.new(:name => name)
    expect_github_request(/github.*\/#{repo}/, false)
    assert ! github_look_a_like_gem.github?
  
    non_github_gem = Hubless::GemDescription.new(:name => 'non_github_gem')
    expect_no_request
    assert ! non_github_gem.github?
    
    user = 'my'
    repo = 'one_too_many_requests'
    name = "#{user}-#{repo}"
    github_error_gem = Hubless::GemDescription.new(:name => name)
    expect_github_request(/github.*\/#{repo}/, false, true)
    assert_raise(Hubless::ServiceError) { github_error_gem.github? }
  end

  def test_multiple_github?
    user = 'my'
    repo = 'github_gem'
    name = "#{user}-#{repo}"
    github_gem = Hubless::GemDescription.new(:name => name)
    expect_github_request(/github.*\/#{repo}/, true)
    assert github_gem.github?
    # tests that number of expected calls is not exceeded
    expect_no_request
    assert github_gem.github?
  
    # setting name should clear cache
    user = 'my'
    repo = 'other_github_gem'
    name = "#{user}-#{repo}"
    github_gem.name = name
    expect_github_request(/github.*\/#{repo}/, true)
    assert github_gem.github?
  end

  def test_gemcutter?
    name = 'my-gemcutter_gem'
    gemcutter_gem = Hubless::GemDescription.new(:name => name)
    expect_gemcutter_request(/gemcutter.*#{name}/, true)
    assert gemcutter_gem.gemcutter?
    
    name = 'my-non_gemcutter_gem'
    non_gemcutter_gem = Hubless::GemDescription.new(:name => name)
    expect_gemcutter_request(/gemcutter.*#{name}/, false)
    assert ! non_gemcutter_gem.gemcutter?
  end
  
  def test_multiple_gemcutter?
    name = 'my-gemcutter_gem'
    gemcutter_gem = Hubless::GemDescription.new(:name => name)
    expect_gemcutter_request(/gemcutter.*#{name}/, true)
    assert gemcutter_gem.gemcutter?
    # tests that number of expected calls is not exceeded
    expect_no_request
    assert gemcutter_gem.gemcutter?
  
    # setting name should clear cache
    name = 'my-other_gemcutter_gem'
    gemcutter_gem.name = name
    expect_gemcutter_request(/gemcutter.*#{name}/, true)
    assert gemcutter_gem.gemcutter?
  end

  def test_install_cmd
    user = 'my'
    repo = 'github_gem'
    name = "#{user}-#{repo}"
    version = '0.1.2'
    gem_description = Hubless::GemDescription.new(:name => name, :version => version)
    expect_github_request(/github.*\/#{repo}/, true)
    assert_equal "gem install #{repo} -v #{version}", gem_description.install_cmd

    user = 'my'
    repo = 'github_gem'
    name = "#{user}-#{repo}"
    version = nil
    gem_description = Hubless::GemDescription.new(:name => name, :version => version)
    expect_github_request(/github.*\/#{repo}/, true)
    assert_equal "gem install #{repo}", gem_description.install_cmd
    
    user = 'my'
    repo = 'github_look_a_like_gem'
    name = "#{user}-#{repo}"
    version = '0.1.2'
    gem_description = Hubless::GemDescription.new(:name => name, :version => version)
    expect_github_request(/github.*\/#{repo}/, false)
    assert_equal "gem install #{name} -v #{version}", gem_description.install_cmd
  end

  def test_uninstall_cmd
    user = 'my'
    repo = 'github_gem'
    name = "#{user}-#{repo}"
    version = '0.1.2'
    gem_description = Hubless::GemDescription.new(:name => name, :version => version)
    expect_no_request
    assert_equal "gem uninstall #{name} -v #{version}", gem_description.uninstall_cmd

    user = 'my'
    repo = 'github_gem'
    name = "#{user}-#{repo}"
    version = nil
    gem_description = Hubless::GemDescription.new(:name => name, :version => version)
    expect_no_request
    assert_equal "gem uninstall #{name}", gem_description.uninstall_cmd
    
    user = 'my'
    repo = 'github_look_a_like_gem'
    name = "#{user}-#{repo}"
    version = '0.1.2'
    gem_description = Hubless::GemDescription.new(:name => name, :version => version)
    expect_no_request
    assert_equal "gem uninstall #{name} -v #{version}", gem_description.uninstall_cmd
  end

end
