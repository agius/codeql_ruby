require 'forwardable'
require 'pathname'

module CodeqlRuby
  class ExtractorFile

    extend Forwardable

    # allow ExtractorFile to be sorted and unique'd based on filepath string
    def_delegator :@filepath, :hash

    attr_reader :filepath, :source_kind

    # these should be kept in sync with files#fromSource in ruby.dbscheme
    SOURCE_KINDS = {
      unknown: 0,
      source: 1,
      library: 2
    }.freeze

    def self.source_kinds
      SOURCE_KINDS
    end

    def initialize(filepath, source_kind: nil)
      @filepath = filepath
      @source_kind = source_kind || :source
    end

    # allow ExtractorFile to be sorted and unique'd based on filepath string
    def eql?(other)
      @filepath.eql?(other)
    end

    def contents
      @contents ||= File.read(filepath)
    end

    def trapfile_name
      @trapfile_name ||= "#{File.basename(filepath, '.rb')}.trap"
    end

    def structure
      @structure ||= begin
        Node.new(Ripper.sexp(contents))
      end
    end

    # https://youtu.be/b8m9zhNAgKs?t=44
    def to_trap
      trapout = []
      idx = 10_000

      folders = Pathname.new(filepath).ascend.to_a.reverse[0..-2]
      prev = nil
      folders.each do |paf|
        simple = File.basename(paf)
        trapout << "##{idx}=@\"#{paf};folder\""
        trapout << "folders(##{idx}, \"#{paf}\", \"#{simple}\")"
        trapout << "containerparent(##{prev},##{idx})" if prev
        prev = idx
        idx += 1
      end

      file_ref = idx
      trapout << "##{file_ref}=@\"#{filepath};sourcefile\""

      basename = File.basename(filepath, '.*')
      extname = File.extname(filepath)
      extname = extname[1..-1] if extname.start_with?('.')
      src_kind = SOURCE_KINDS[source_kind]

      trapout << "files(##{file_ref},\"#{filepath}\",\"#{basename}\",\"#{extname}\",#{src_kind})"
      trapout << "containerparent(##{prev}, ##{file_ref})"

      idx += 1
      loc_ref = idx
      trapout << "##{loc_ref}=@\"loc,{##{file_ref}},0,0,0,0\""
      trapout << "locations_default(##{loc_ref}, ##{file_ref}, 0, 0, 0, 0)"

      visitor = Visitor.new(idx, file_ref)
      visitor.visit(structure)
      trapout += visitor.trap_entries

      num_lines = contents.count("\n")

      trapout << "numlines(##{prev}, #{num_lines}, #{visitor.num_code}, #{visitor.num_comment})"
      trapout.join("\n")
    end
  end
end
