require 'bundler'
require 'rspec/core/rake_task'

Bundler::GemHelper.install_tasks

task :default => [:spec]
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = "--color"
end
