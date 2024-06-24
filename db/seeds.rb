ENV["FIXTURES_PATH"] = "spec/fixtures"

::Rake.application["db:fixtures:load"].invoke

::Genre.rebuild_index!
::Author.rebuild_index!
::Book.rebuild_index!
