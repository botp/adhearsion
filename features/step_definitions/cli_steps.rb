require 'timeout'

Then /^I should see the usage message$/ do
  steps %Q{
    Then the output should contain "Tasks:"
    Then the output should contain "ahn create"
    Then the output should contain "ahn start"
    Then the output should contain "ahn daemon"
    Then the output should contain "ahn version"
    Then the output should contain "ahn help"
  }
end

# TODO: Remove after pull request is merged in cucumber.rb from Aruba
When /^I terminate the interactive process$/ do
  terminate_processes!
end

When /^I wait (\d+) seconds?$/ do |arg1|
  sleep arg1.to_i
end

# TODO: Remove after pull request is merged in cucumber.rb from Aruba
When /^I wait for (?:output|stdout) to contain "([^"]*)"$/ do |expected|
  Timeout::timeout(exit_timeout) do
    loop do
      break if assert_partial_output_interactive(expected)
      sleep 0.1
    end
  end
end

Given /^that I create a valid app under "([^"]*)"$/ do |path|
  steps %Q{
    When I run `ahn create #{path}`
    Then there should be a valid adhearsion directory named "#{path}"
  }
end

Then /^there should be a valid adhearsion directory named "([^"]*)"$/ do |path|
  steps %Q{
    Then a directory named "#{path}" should exist
  }

  cd(path)
  steps %Q{
    Then the following directories should exist:
      | lib |
      | config |
    Then the following files should exist:
      | Gemfile |
      | README |
      | Rakefile |
      | config/adhearsion.rb |
      | config/environment.rb |
  }

  ## NOTE: Aruba's cd method is not really changing directories
  ## Either we use cd or we need absolute path... could not figure out cleaner
  ## way to get back to previous dir.
  dotsback=1.upto(path.split(File::SEPARATOR)[0..-1].count).collect {|x| ".."}.join(File::SEPARATOR)
  dotsback.shift if dotsback[0].is_a?(String) and dotsback[0].empty?
  cd(dotsback)
end


Given /^that I start a ahn daemon under "([^"]*)"$/ do |path|
  steps %Q{
    Given that I create a valid app under "#{path}"
    And I run `ahn daemon #{path} --pid-file=ahn.pid`
  }
end

When /^I terminate the process using the pid file "([^"]*)"$/ do |pidfile|
  check_file_presence([pidfile], true)
  prep_for_fs_check do
    pid = File.read(pidfile).to_i
    Process.kill("TERM", pid)
  end
end

When /^I check for the process with the pid file "([^"]*)" it should be running$/ do |pidfile|
  check_file_presence([pidfile], true)
  pending # that pid looks awesome where is the process?
end

Then /^the process identified by the pid file "([^"]*)" should be stopped$/ do |pidfile|
  steps %Q{When I terminate the process using the pid file "#{pidfile}"}
end
