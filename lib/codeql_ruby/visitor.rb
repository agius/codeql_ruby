module CodeqlRuby
  class Visitor

    IDX_START = 10_000

    attr_reader :idx, :trap_entries, :num_code, :num_comment, :file_ref

    def initialize(idx_start, file_ref)
      @idx = idx_start
      @file_ref = file_ref
      @num_code = 0
      @num_comment = 0
      @trap_entries = []
    end

    def visit(node)
      @num_code += 1
      if node.leaf_node?
        @trap_entries += trap_for_leaf(node)
      else
        node.children.each { |child| visit(child) }
      end
      @trap_entries
    end

    def trap_for_leaf(node)
      trapper_keeper = []

      @idx += 1
      leaf_idx = idx
      trapper_keeper << "##{leaf_idx}=*"

      @idx += 1
      loc_idx = idx

      trapper_keeper << "##{loc_idx}=@\"loc,{##{file_ref}},#{node.start_line},#{node.start_col},#{node.end_line},#{node.end_col}\""
      trapper_keeper << "locations_default(##{loc_idx}, ##{file_ref}, #{node.start_line}, #{node.start_col}, #{node.end_line}, #{node.end_col})"
      trapper_keeper << "has_location(##{leaf_idx}, ##{loc_idx})"
      trapper_keeper << "leaf_nodes(##{leaf_idx}, \"#{node.sexp[1]}\", #{node.start_line}, #{node.start_col})"
      trapper_keeper
    end
  end
end
