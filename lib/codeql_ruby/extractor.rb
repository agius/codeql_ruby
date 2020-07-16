require 'ripper'
require 'fileutils'
require 'zlib'
require 'set'

module CodeqlRuby
  class Extractor

    IDX_START = 10_000

    attr_reader :trap_dir, :wip_dir, :src_dir

    # env vars set by codeql binaries / scripts
    #
    # CODEQL_EXTRACTOR_RUBY_SOURCE_ARCHIVE_DIR=<db_dir>/src
    # CODEQL_PLATFORM=osx64
    # CODEQL_EXTRACTOR_RUBY_LOG_DIR=<db_dir>/log
    # CODEQL_DIST=/Users/<whoami>/codeql-home/codeql
    # CODEQL_EXTRACTOR_RUBY_SCRATCH_DIR=<db_dir>/working
    # CODEQL_JAVA_HOME=/Users/<whoami>/codeql-home/codeql/tools/osx64/java
    # CODEQL_EXTRACTOR_RUBY_WIP_DATABASE=<db_dir>
    # CODEQL_EXTRACTOR_RUBY_TRAP_DIR=<db_dir>/trap/ruby
    # JAVA_MAIN_CLASS_50625=com.semmle.cli2.CodeQL

    def initialize(to_extract = nil)
      to_extract = Dir.pwd if to_extract.nil?
      @wip_dir = setup_env_dir('CODEQL_EXTRACTOR_RUBY_WIP_DATABASE')
      @trap_dir = setup_env_dir('CODEQL_EXTRACTOR_RUBY_TRAP_DIR')
      @src_dir = setup_env_dir('CODEQL_EXTRACTOR_RUBY_SOURCE_ARCHIVE_DIR')
      if File.directory?(to_extract)
        @ex_dir = File.expand_path(to_extract)
      elsif File.file?(to_extract)
        @ex_file = File.expand_path(to_extract)
      else
        raise ArgumentError.new("to_extract must be a file or directory, found: #{to_extract}")
      end
      @files = Set.new
    end

    def setup_env_dir(evar)
      env_dir = ENV[evar]
      raise "Environment variable #{evar} not set" if env_dir.nil? || env_dir.size == 0

      dirpath = File.expand_path(env_dir)
      FileUtils.mkdir_p(dirpath)
      return dirpath
    end

    def extract!
      if @ex_dir
        Dir.glob File.join(@ex_dir, '**', '*.rb') do |srcpath|
          extractor_file = ExtractorFile.new(File.expand_path(srcpath), source_kind: :source)
          extract_file(extractor_file)
        end
      elsif @ex_file
        extractor_file = ExtractorFile.new(@ex_file, source_kind: :source)
        extract_file(extractor_file)
      else
        raise 'Nothing to extract!'
      end
    end

    def extract_file(ex_file)
      # Set.add? returns nil if file is already in the set
      return unless @files.add? ex_file

      copy_file_to_src(ex_file.filepath)
      trapfile_for_code(ex_file)
    end

    def copy_file_to_src(filepath)
      src = File.expand_path(filepath)
      dest = File.join(src_dir, src)
      FileUtils.mkdir_p(File.dirname(dest))
      FileUtils.cp(src, dest)
    end

    def trapfile_for_code(extractor_file)
      trap_contents = extractor_file.to_trap

      trapfile_path = File.join(trap_dir, extractor_file.trapfile_name)
      File.open(trapfile_path, 'w') do |f|
        f.write(trap_contents)
      end

      gz_path = "#{trapfile_path}.gz"
      Zlib::GzipWriter.open(gz_path) do |gz|
        gz.mtime = File.mtime(trapfile_path)
        gz.orig_name = File.basename(trapfile_path)
        gz.write IO.binread(trapfile_path)
      end
    end
  end
end
