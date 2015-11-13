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

    return unless params['symbol']
    @symbol = params['symbol'].upcase
    # @search_results = Company.where("symbol like :prefix", prefix: "%#{@symbol}%")

    @company = Company.find_by(symbol: @symbol)
    puts "===================="
    puts @company
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
    puts "===================="
  rescue => e
    puts e.message
    render file: 'public/404.html', status: :not_found, layout: false
  end

  def ticker_json(companies)
    list = companies.map(&:symbol)
    list.to_json
  end

  def home_params
    params.require(:symbol)
  end
end