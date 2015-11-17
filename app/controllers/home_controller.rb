require 'yahoo_finance'
require 'sentiment_analyzer'

class HomeController < ApplicationController
  def dashboard
    return unless current_user
    # get IDs of companies that are currently favorited
    user_favorite_active = current_user.favorite_companys.where(active: true).map(&:company_id)
    # Set the current user companies to the active ones
    @user_companies = current_user.companys.where(id: user_favorite_active)

    @tickers = ticker_json(Company.all)

    # return unless params['symbol']
    if params['symbol'].present? and not params['symbol'].nil?
      @symbol = params['symbol'].upcase

      @company = Company.find_by(symbol: @symbol)
      if @company
        @quotes = Finance.get_quotes(@symbol, false)
        @hist = Finance.get_quotes(@symbol, true)

        @sentiments = SentimentAnalyzer.get_results(@symbol)
        @symbol_rating = @sentiments[:symbol_rating]
        @num_tweets = @sentiments[:num_tweets]
        @results = @sentiments[:results]
      else
        @search_results = Company.where("symbol like :prefix", prefix: "%#{@symbol}%")
      end
    else
      @user_companies_quotes = Array.new
      @user_companies.each do |c|
        quote = Finance.get_quotes(c.symbol, false)
        @user_companies_quotes.push(quote)
      end
    end
  rescue => e
    puts e.message
    render file: 'public/404.html', status: :not_found, layout: false
  end

  def ticker_json(companies)
    list = companies.map(&:symbol)
    list.to_json
  end

end