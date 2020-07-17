require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'fileutils'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

RSpec::Core::RakeTask.new('rspec:ci') do |t|
  t.rspec_opts = "--format documentation --color --require spec_helper"
end

desc 'Build & install gem, run specs with CI output settings'
task 'spec:ci' => ['install', 'rspec:ci']
