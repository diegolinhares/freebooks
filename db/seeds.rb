ENV["FIXTURES_PATH"] = "spec/fixtures"

::Rake.application["db:fixtures:load"].invoke
