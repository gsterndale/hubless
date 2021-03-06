# hubless

Search your local gem repository for gems installed from GitHub that have since moved to Gemcutter and get instructions on how to reinstall them.

## Command line usage

	$ hubless [-i|-h]

## Sample output

	Found 184 local gems. Of those, 53 look like GitHub gems.

	Searching GitHub for matching repositories...
	YNYYYYNNNYNNNNNNNNNYYNNNNNNYNNNYNNNNNNYYNYYYNYNNNNNYN
	Found 17 repositories on GitHub.

	Searching for matching gems on Gemcutter...
	NNYYNYNYNYYYYYNNN
	Found 9 gems on Gemcutter.

	To uninstall these GitHub gems run:
	gem uninstall thoughtbot-shoulda -v 2.10.1
	gem uninstall thoughtbot-factory_girl -v 1.2.1
	gem uninstall rubyist-aasm -v 2.1.1
	gem uninstall relevance-rcov -v 0.8.6
	gem uninstall mojombo-chronic -v 0.3.0
	gem uninstall mislav-will_paginate -v 2.3.11
	gem uninstall jscruggs-metric_fu -v 1.1.5
	gem uninstall javan-whenever -v 0.3.6

	To reinstall these gems from Gemcutter run:
	gem install shoulda -v 2.10.1
	gem install factory_girl -v 1.2.1
	gem install aasm -v 2.1.1
	gem install rcov -v 0.8.6
	gem install chronic -v 0.3.0
	gem install will_paginate -v 2.3.11
	gem install metric_fu -v 1.1.5
	gem install whenever -v 0.3.6

## Blacklist

Hubless now has a blacklist of gems with unfortunate names, that should not be reinstalled. For example: [sqlite3-ruby](http://github.com/sqlite3/ruby).

If you encounter any of these gems, please fork this project, add them to BLACKLIST.yml and submit a Pull Request. Thanks!

## Copyright

Copyright (c) 2010 Greg Sterndale. See LICENSE for details.
