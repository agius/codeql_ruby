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
end
