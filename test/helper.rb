require 'rubygems'
require 'test/unit'
require 'ruby-debug'
require 'mocha'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'hubless'
require 'application'

class Test::Unit::TestCase

  def expect_no_request
     Net::HTTP.expects(:get).never
  end

  def expect_github_request(uri_regex, exist, error=false)
    Net::HTTP.expects(:get).
              once.
              with{|uri| uri.to_s =~ uri_regex }.
              returns case
                when error
                  "--- \nerror: \n- error: too many requests\n"
                when exist
                  "--- \nrepository: \n  :description: Description here\n  :forks: 0\n  :url: http://github.com/some_user/some_repo\n  :fork: false\n  :open_issues: 0\n  :watchers: 1\n  :private: false\n  :name: some_repo\n  :owner: some_user\n"
                else
                  "--- \nerror: \n- error: repository not found\n"
                end
  end

  def expect_gemcutter_request(uri_regex, exist, error=false)
    Net::HTTP.expects(:get).
              once.
              with{|uri| uri.to_s =~ uri_regex }.
              returns case
                when error
                  "Error"
                when exist
                  %Q{{"version_downloads":137674,"info":"    Rails is a framework for building web-application using CGI, FCGI, mod_ruby, or WEBrick\n    on top of either MySQL, PostgreSQL, SQLite, DB2, SQL Server, or Oracle with eRuby- or Builder-based templates.\n","project_uri":"http://gemcutter.org/gems/rails","name":"rails","version":"2.3.5","gem_uri":"http://gemcutter.org/gems/rails-2.3.5.gem","downloads":218523,"authors":"David Heinemeier Hansson"}}
                else
                  "This rubygem could not be found."
                end
  end

end
