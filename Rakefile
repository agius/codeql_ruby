require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'fileutils'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

desc 'Build & install gem, run specs'
task 'spec:ci' => ['install', 'spec']
