require "bundler/setup"
require "codeql_ruby"

require "fileutils"
require "json"
require "pp"
require "open3"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

class CodeqlRunner

  attr_reader :gem_root, :codeql_path, :db_dir, :db_name, :spec_dir, :bqrs_path

  def self.codeql_path
    @codeql_path ||= ENV.fetch('CODEQL_PATH') do
      File.expand_path('~/codeql-home/codeql/codeql')
    end
  end

  def self.results_for_db(db_name)
    runner = self.new(db_name)
    runner.clean_db!
    runner.create_db!
    runner.run_query!
    runner.results_json
  end

  def initialize(db_name)
    @db_name = db_name

    @gem_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
    @db_dir = File.join(gem_root, 'build', db_name)
    @bqrs_path = File.join(db_dir, 'results.bqrs')
    @spec_dir = File.join(gem_root, 'spec', db_name)
    @codeql_path = self.class.codeql_path
  end

  # bang_methods! modify state on disk
  #
  # I know, yet another meaning for ! methods, but I wanted to have something to
  # indicate the wild side effects here
  def clean_db!
    FileUtils.rm_rf(db_dir)
  end

  def create_db!
    cmd_args = [
      codeql_path,
      'database',
      'create',
      db_dir,
      '--language=ruby',
      '--mode=light',
      '--no-finalize-dataset',
      '--verbose'
    ]
    system!(cmd_args.join(' '), chdir: spec_dir)
  end

  def run_query!
    query_path = File.join(spec_dir, 'example.ql')
    cmd_args = [
      codeql_path,
      'query',
      'run',
      "--database=#{db_dir}",
      "--output=#{bqrs_path}",
      query_path
    ]
    system!(cmd_args.join(' '), chdir: spec_dir)
  end

  def results_json
    cmd_args = [
      codeql_path,
      'bqrs',
      'decode',
      '--format=json',
      bqrs_path
    ]
    results = system!(cmd_args.join(' '))
    JSON.parse(results)
  end

  protected

  def system!(cmd, opts = {})
    stdout_str, stderr_str, status = Open3.capture3(cmd, opts)
    if status != 0
      pp Hash[
        cmd: cmd,
        status: status,
        stdout: stdout_str,
        stderr: stderr_str
      ]
      raise "failed with status #{status} while running command #{cmd}"
    end

    stdout_str
  end
end
