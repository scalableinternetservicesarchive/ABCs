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

    cached_result = get_cached_data(symbol, is_hist)
    if is_hist 
      return fetch_finance_hist symbol unless cached_result
      cached_result.hist_data
    else
      return fetch_finance_curr symbol unless cached_result
      JSON.parse(cached_result.curr_data)
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

      days_past = 365
      hist = YahooFinance::get_historical_quotes_days(symbol, days_past)
      histJSON = hist.map { |e| {id: e}}.to_json

      # Caching the historical data
      cache(histJSON, symbol, true)

      return histJSON
    end

    # Download and cache the current quote for target stock
    def fetch_finance_curr(symbol)
      # Get new data
      quote = YahooFinance::get_standard_quotes symbol
      quoteJSON = quote[symbol].to_json
      cache(quoteJSON, symbol, false)

      return JSON.parse(quoteJSON)
    end

    # Stores the results in the DB
    def cache(data, symbol, is_hist)
      # :type is an enum which identifies historical (0) or current(1) data
      data_type = is_hist ? :hist_data : :curr_data
      cache_type = is_hist ? 0 : 1
      yhoo_cache =
        FinanceCache.new(data_type => data,
                         category: cache_type,
                         company_id: Company.find_by(symbol: symbol).id)
      yhoo_cache.save
    end

    # Checks cache for stored stock data
    def get_cached_data(symbol, is_hist)
      company = Company.find_by(symbol: symbol)
      type = is_hist ? 0 : 1
      cached = FinanceCache.find_by(company_id: company.id, category: type)

      # Only keep historical data for a day, and current for 15 minutes
      exp_period = is_hist ? 1.day : 1.day
      if cached.created_at < Time.zone.now - exp_period
        cached.destroy
        cached = nil
      end

      return cached
    rescue
      return nil
    end
  end
end
