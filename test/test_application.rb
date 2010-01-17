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

end