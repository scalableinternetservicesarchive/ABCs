require 'analyzer'

# Test controller for demoing the sentiment analysis engine
class SentimentController < ApplicationController
  def check
    analyzer = Analyzer.new
    return unless params['tweet']
    tweet = params['tweet']
    @result = analyzer.process(tweet)
  end

  private

  def sent_params
    params.require(:tweet)
  end
end
