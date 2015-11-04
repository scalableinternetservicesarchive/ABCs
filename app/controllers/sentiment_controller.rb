require 'sentiment_analyzer'

# Test controller for demoing the sentiment analysis engine
class SentimentController < ApplicationController
  def check
    # Get list of tickers for autocomplete
    @tickers = ticker_json(Company.all)
    return unless params['symbol']

    # Get cached symbol if possible
    @symbol = params['symbol']
    @sentiments = SentimentAnalyzer.get_results(@symbol)
    @symbol_rating = @sentiments[:symbol_rating]
    @num_tweets = @sentiments[:num_tweets]
    @results = @sentiments[:results]
  rescue => e
    puts e.message
    render file: 'public/404.html', status: :not_found, layout: false
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
