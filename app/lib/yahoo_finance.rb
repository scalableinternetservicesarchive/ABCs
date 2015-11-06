require 'yahoofinance'
require 'json'

# Gets stock data from Yahoo Finance
class Finance
  # Looks up symbol in the finance cache. Historical data is current for up to 
  # a day in the cache and current data for 15 minutes. After that new data 
  # must be fetched
  def self.get_quotes(symbol, is_hist)
    symbol.upcase!
    if Company.find_by(symbol: symbol).nil?
      fail(ArgumentError,
           "#{symbol} is an invalid symbol! Not found in company database")
    end

    if is_hist 
      fetch_finance_hist(symbol)
    else
      fetch_finance_curr(symbol)
    end
  end

  class << self
    private

    # Download and cache the historical data for all the stocks we keep track of
    def fetch_finance_hist(symbol)
      # Getting the historical quote data as a raw array.
      # The elements of the array are:
      #   [0] - Date
      #   [1] - Open
      #   [2] - High
      #   [3] - Low
      #   [4] - Close
      #   [5] - Volume
      #   [6] - Adjusted Close

      days_past = 36500
      hist = YahooFinance::get_historical_quotes_days(symbol, days_past)
      histJSON = hist.map { |e| {:id => e}}.to_json

      { hist: histJSON }
    end

    # Download and cache the current quote for target stock
    def fetch_finance_curr(symbol)
      # Get new data
      quote = YahooFinance::get_standard_quotes(symbol)

      { quotes: quote }
    end
  end
end
