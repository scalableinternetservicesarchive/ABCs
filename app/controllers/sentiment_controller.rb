require 'analyzer'

# Test controller for demoing the sentiment analysis engine
class SentimentController < ApplicationController
  # rubocop:disable AbcSize, MethodLength
  def check
    @tickers = ticker_json(Company.all)
    return unless params['symbol']
    analyzer = Analyzer.new
    @symbol = params['symbol'].upcase
    # rubocop:disable GlobalVars
    @tweets = $twitter.search('$' + @symbol + ' -rt',
                              result_type: 'mixed',
                              count: 20).take(100)
    # rubocop:enable GlobalVars
    @results = []
    total_points = 0
    @tweets.each do |tweet|
      res = analyzer.process(tweet.text)
      # Skip adding neutral
      next unless res
      if res.sentiment == ':)'
        total_points += res.overall_probability
      elsif res.sentiment == ':('
        total_points -= res.overall_probability
      end
      @results << res
    end
    @symbol_rating = total_points / @results.length * 100
  end

  private

  def ticker_json(companies)
    list = companies.map(&:symbol)
    list.to_json
  end

  def sent_params
    params.require(:tweet)
  end
end
