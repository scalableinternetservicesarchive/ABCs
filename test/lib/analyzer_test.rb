require 'analyzer.rb'
require 'test_helper'

class AnalyzerTest < ActiveSupport::TestCase
  test 'Run analyzer on small string' do
    a = Analyzer.new
    assert a.process('hello world').to_json.eql?
    '{"text":"hello world","probability":0.7627410869620818,"sentiment":":)"}'
  end
end
