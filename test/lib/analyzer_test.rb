require 'analyzer.rb'
require 'test_helper'

class AnalyzerTest < ActiveSupport::TestCase
  test 'Run analyzer on small string' do
    a = Analyzer.new
    s = a.process('hello world')
    # hello world should have positive sentiment.
    # probability differs slightly due to new training model
    assert_equal(s.sentiment, ':)')
  end
end
