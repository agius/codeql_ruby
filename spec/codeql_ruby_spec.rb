RSpec.describe CodeqlRuby do
  it "has a version number" do
    expect(CodeqlRuby::VERSION).not_to be nil
  end

  it "extracts the things" do
    filepath = File.join(File.expand_path(File.dirname(__FILE__)), 'unsafe_command.rb')
    results = described_class.extract(filepath)
    expect(results.first).to eq(:program)
  end
end
