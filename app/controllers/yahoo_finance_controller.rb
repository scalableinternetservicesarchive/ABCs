require 'yahoofinance'

class YahooFinanceController < ApplicationController
  def get_data
    ticker = params["stock"].upcase

    #quote_type = YahooFinance::StandardQuote
    @quotes = YahooFinance::get_standard_quotes(ticker)

    # To get rid of the YahooFinance::StandardQuote thing at the top:
    #   try changing the stocks.html.erb to the following:
    #   if @ticker
    #     YahooFinance::get_quotes(YahooFinance::StandardQuote, ticker) do |qt|
    #       qt
    #     end
    #   end

    # Getting the historical quote data as a raw array.
    # The elements of the array are:
    #   [0] - Date
    #   [1] - Open
    #   [2] - High
    #   [3] - Low
    #   [4] - Close
    #   [5] - Volume
    #   [6] - Adjusted Close

    # Below are 2 methods to get the historical data
    #
    #
    # The first downloads up to 100 years worth of quotes as raw array
    # If using raw array, can use row.join on each obj to display
    @hist = YahooFinance::get_historical_quotes_days(ticker, 30)
    @histJSON = @hist.map { |e| {:id => e}}.to_json

    # The second way
    # Downloading as YahooFinance::HistoricalQuote object
    # If using this method, change the following in stocks.html.erb
    #   for each object, hq: hq.symbol, hq.date, hq.open, hq.high, hq.low
    #                        hq.close, hq.volume, hq.adjClose
    #
    # ****to_json has some weird output when using this method*****
    #
    #@hist = YahooFinance::get_HistoricalQuotes_days(ticker, 36500)
    #@histJSON = @hist.map { |e| {:id => e}}.to_json

    render 'stocks'
  end

  private
  def stock_ticker
    params.require(:stock)
  end
end
