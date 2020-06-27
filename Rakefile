require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'fileutils'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

namespace :endtoend do
  codeql_path   = File.expand_path('~/codeql-home/codeql/codeql')
  example_repo  = File.expand_path(File.dirname(__FILE__))
  example_db    = File.expand_path('~/Projects/codeql-stuff/codeql-ruby-example')
  queries_repo  = File.expand_path('~/Projects/vscode-codeql-starter/codeql-custom-queries-ruby')

  def system!(*args)
    puts "RAKE: Running command #{args.inspect}"

    success = system(*args)
    if success
      puts "RAKE: Command #{args.inspect} succeeded"
      return true
    end

    raise "RAKE: Command #{args.inspect} failed with status: #{$?}"
  end

  task default: [
    :pre_clean,
    :gem_install,
    :gen_db,
    :gen_stats,
    :exec_query
  ]

  task :pre_clean do
    puts "RAKE pre_clean: removing everything at #{example_db}"
    FileUtils.rm_rf(example_db)
  end

  task :gem_install do
    Rake::Task['install'].execute
  end

  task :gen_db do
    cmd_args = [
      codeql_path,
      'database',
      'create',
      example_db,
      '--language=ruby',
      '--mode=light',
      '--no-finalize-dataset',
      '--verbose'
    ]
    system!(cmd_args.join(' '), chdir: example_repo)
  end

  task :gen_stats do
    dbscheme_path = File.join(example_repo, 'ql', 'src', 'ruby.dbscheme')
    dest = File.join(example_db, 'ruby.dbscheme')
    puts "RAKE gen_stats: copying ruby.dbscheme to #{dest}"
    FileUtils.cp dbscheme_path, dest

    statsfile_path = "#{dbscheme_path}.stats"
    puts "RAKE gen_stats: creating ruby.dbscheme.stats at #{statsfile_path}"

    dataset_path = File.join(example_db, 'db-ruby')
    cmd_args = [
      codeql_path,
      'dataset',
      'measure',
      "--output=#{statsfile_path}",
      dataset_path
    ]
    system!(cmd_args.join(' '), chdir: example_repo)
  end

  task :exec_query do
    query_path = File.join(queries_repo, 'example.ql')
    cmd_args = [
      codeql_path,
      'query',
      'run',
      "--database=#{example_db}",
      "--search-path=#{example_repo}",
      query_path
    ]
    system!(cmd_args.join(' '), chdir: queries_repo)
  end
end

desc 'Rebuild & reinstall gem, build example db and run query'
task endtoend: "endtoend:default"
