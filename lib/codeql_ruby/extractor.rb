require 'ripper'
require 'fileutils'
require 'zlib'

module CodeqlRuby
  class Extractor

    IDX_START = 10000

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

    def initialize
      @wip_dir = setup_env_dir('CODEQL_EXTRACTOR_RUBY_WIP_DATABASE')
      @trap_dir = setup_env_dir('CODEQL_EXTRACTOR_RUBY_TRAP_DIR')
      @src_dir = setup_env_dir('CODEQL_EXTRACTOR_RUBY_SOURCE_ARCHIVE_DIR')
    end

    def setup_env_dir(evar)
      env_dir = ENV[evar]
      raise "Environment variable #{evar} not set" if env_dir.nil? || env_dir.size == 0

      dirpath = File.expand_path(env_dir)
      FileUtils.mkdir_p(dirpath)
      return dirpath
    end

    def extract!
      src_file = Dir['**/*.rb'].find { |p| p =~ /unsafe_command\.rb$/ }
      expanded_path = File.expand_path(src_file)
      extract_file(expanded_path)
    end

    def extract_file(filepath)
      copy_file_to_src(filepath)
      trapfile_for_code(filepath)
    end

    def copy_file_to_src(filepath)
      src = File.expand_path(filepath)
      dest = File.join(src_dir, src)
      FileUtils.mkdir_p(File.dirname(dest))
      FileUtils.cp(src, dest)
    end

    def trapfile_for_code(filepath)
      contents = File.read(filepath)
      structure = Ripper.sexp(contents)
      trap_contents = ""
      idx = IDX_START
      Node.new(structure).visit do |leaf_node|
        idx += 1
        trap_contents << "leaf_nodes(#{idx}, \"#{leaf_node.sexp[1]}\", #{leaf_node.sexp[2][0]}, #{leaf_node.sexp[2][1]})"
      end

      trapfile_name = "#{File.basename(filepath, '.rb')}.trap"
      trapfile_path = File.join(trap_dir, trapfile_name)
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

    class Node
      attr_reader :sexp

      def initialize(sexp)
        @sexp = sexp
      end

      def visit(&block)
        if leaf_node?
          yield self
        elsif sexp.respond_to?(:each)
          sexp.each { |elem| Node.new(elem).visit(&block) }
        else
          # noop
        end
      end

      def leaf_node?
        sexp.is_a?(Array) &&
          sexp[0].is_a?(Symbol) &&
          sexp[1].is_a?(String) &&
          sexp[2].is_a?(Array) && sexp[2].size == 2
      end
    end
  end
end
