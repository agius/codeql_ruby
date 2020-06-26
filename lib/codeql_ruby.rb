require "codeql_ruby/version"
require "codeql_ruby/extractor"

module CodeqlRuby
  class Error < StandardError; end

  module_function

  def extract(filepath)
    Extractor.new(filepath).extract!
  end
end
