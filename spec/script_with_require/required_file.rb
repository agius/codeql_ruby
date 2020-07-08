class RequiredFile
  attr_reader :fullpath

  def initialize
    @fullpath = File.expand_path(__FILE__)
  end
end