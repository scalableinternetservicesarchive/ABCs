require 'yahoo_finance'

class YahooFinanceController < ApplicationController
  def stocks
    # Get list of tickers for autocomplete
    @tickers = ticker_json(Company.all)
    return unless params['symbol']

    # get cached symbol if possible
    @symbol = params['symbol']
    @quotes = Finance.get_quotes(@symbol, false)
    @hist = Finance.get_quotes(@symbol, true)
  rescue => e
    puts e.message
    render file: 'public/404.html', status: :not_found, layout: false
  end

  private
  def ticker_json(companies)
    list = companies.map(&:symbol)
    list.to_json
  end

  def finance_params
    params.require(:symbol)
  end
end
