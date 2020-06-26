require 'ripper'

module CodeqlRuby
  class Extractor

    attr_reader :filepath

    def initialize(filepath)
      @filepath = filepath
    end

    def trap_dir
      return @trap_dir if @trap_dir

      @trap_dir ||= ENV['CODEQL_EXTRACTOR_RUBY_TRAP_DIR']
      @trap_dir ||= ENV['TRAP_FOLDER']
      raise 'no trap_dir found!' if @trap_dir.nil?

      @trap_dir
    end

    def extract!
      contents = File.read(filepath)
      structure = Ripper.sexp(contents)
      output = File.open(File.join(trap_dir, 'output.rb.trap'), 'w')
      idx = 0
      Node.new(structure).visit do |leaf_node|
        idx += 1
        output.puts "leaf_nodes(#{id}, \"#{leaf_node.sexp[1]}\", #{leaf_node.sexp[2][0]}, #{leaf_node.sexp[2][1]})"
      end
      output.close
    end

    class Node
      attr_reader :sexp

      def initialize(sexp)
        @sexp = sexp
      end

      def visit
        if is_leaf_node?
          yield self
        else
          sexp.each { |elem| Node.new(elem).visit }
        end
      end

      def leaf_node?
        sexp[0].is_a?(Symbol) &&
          sexp[1].is_a?(String) &&
          sexp[2].is_a?(Array) && sexp[2].size == 2
      end
    end
  end
end
