module CodeqlRuby
  class Node
    attr_reader :sexp, :children

    def initialize(sexp)
      @sexp = sexp
      @children = if leaf_node?
        []
      else
        Array(sexp).map { |item| Node.new(item) if item.is_a?(Array) }.compact
      end
    end

    def children?
      !children.empty?
    end

    def start_line
      return nil unless leaf_node?

      sexp[2][0]
    end

    def end_line
      start_line
    end

    def start_col
      return nil unless leaf_node?

      sexp[2][1]
    end

    def end_col
      return nil unless leaf_node?

      start_col + sexp[1].size
    end

    def leaf_node?
      return @leaf_node unless @leaf_node.nil?

      @leaf_node = sexp.is_a?(Array) &&
        sexp[0].is_a?(Symbol) &&
        sexp[1].is_a?(String) &&
        sexp[2].is_a?(Array) && sexp[2].size == 2
    end
  end
end
