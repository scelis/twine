require 'bundler'
require 'rake'
require 'rake/testtask'

# Add build, install, and release tasks.
Bundler::GemHelper.install_tasks

Rake::TestTask.new do |t|
  t.test_files = %w(test/twine_test.rb)
end

task :default => :test
