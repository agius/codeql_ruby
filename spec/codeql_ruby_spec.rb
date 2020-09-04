require 'spec_helper'

RSpec.describe CodeqlRuby do
  it "has a version number" do
    expect(CodeqlRuby::VERSION).not_to be nil
  end

  it "extracts a db, runs a query, and generates JSON results" do
    results = CodeqlRunner.results_for_db('base_unsafe_script')
    tuples = results.dig('#select', 'tuples')

    expect(tuples).to include(['eval', 'This is a leaf node.'])
  end

  it "extracts a directory as a db and queries it" do
    results = CodeqlRunner.results_for_db('script_with_require')
    tuples = results.dig('#select', 'tuples')

    expect(tuples).to include(['RequiredFile', 'This is a leaf node.'])
  end

  it "extracts a file to relevant trap structures" do
    filepath = File.expand_path(File.join(File.dirname(__FILE__), 'script_with_require', 'script_with_require.rb'))
    ef = CodeqlRuby::ExtractorFile.new(filepath)
    results = ef.to_trap

    expect(results).to be_a(String)
  end

  it "extracts Location info from LeafNodes" do
    results = CodeqlRunner.results_for_db('leaf_node_location')
    tuples = results.dig('#select', 'tuples')

    expect(tuples).to include([{'label'=>'LeafNode'}, 'puts', 'leaf_node_location.rb:1'])
  end
end
