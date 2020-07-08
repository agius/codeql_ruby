require 'codeql_ruby/version'
require 'codeql_ruby/node'
require 'codeql_ruby/visitor'
require 'codeql_ruby/extractor_file'
require 'codeql_ruby/extractor'

module CodeqlRuby
  class Error < StandardError; end

  module_function

  def extract(file_or_dir = nil)
    Extractor.new(file_or_dir).extract!
  end
end
