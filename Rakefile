require 'bundler'
Bundler::GemHelper.install_tasks

desc "Run all RSpec test examples"
task :spec do
  require 'rspec'
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new do |spec|
    spec.rspec_opts = ["-c", "-f progress"]
    spec.pattern = 'spec/**/*_spec.rb'
  end
end

task :default => :spec