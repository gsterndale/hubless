require 'helper'

class TestApplication < Test::Unit::TestCase

  def test_run
    hubless = mock(
      :gem_breakdown          => true,
      :github_repos           => true,
      :gemcutter_gems         => true,
      :uninstall_instructions => true,
      :install_instructions   => true
    )
    Hubless.expects(:new).returns(hubless)
    Hubless::Application.run
  end

  def test_run_with_i
    hubless = mock(
      :gem_breakdown          => true,
      :github_repos           => true,
      :gemcutter_gems         => true,
      :uninstall_instructions => true,
      :install_gems           => true
    )
    Hubless.expects(:new).returns(hubless)
    Hubless::Application.run('-i')
  end

  def test_run_with_h
    original_stdout = $stdout
    fake_stdout = mock
    fake_stdout.stubs(:write)
    $stdout = fake_stdout
    fake_stdout.expects(:puts).at_least_once
    Hubless.expects(:new).never
    Hubless::Application.run('-h')
  ensure
    $stdout = original_stdout
  end

end