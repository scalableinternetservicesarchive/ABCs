require 'yahoofinance'
require 'json'

# Gets stock data from Yahoo Finance
class Finance
  # Looks up symbol in the finance cache. Historical data is current for up to 
  # a day in the cache and current data for 15 minutes. After that new data 
  # must be fetched
  def self.get_quotes(symbol, hist)
    symbol.upcase!
    if Company.find_by(symbol: symbol).nil?
      fail(ArgumentError,
           "#{symbol} is an invalid symbol! Not found in company database")
    end

#    cached_result = get_cached_data(symbol, hist)
    if hist 
      return fetch_finance_hist(symbol)# unless cached_result
    else
      return fetch_finance_curr(symbol)# unless cached_result
    end

    { quotes: cached_result.curr_data,
      hist: cached_result.hist_data }
      #status?
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

      # Below are 2 different methods to get the historical data
      
      # The first downloads up to 100 years worth of quotes as raw array
      # If using raw array, can use row.join on each obj to display
      days_past = 36500
      hist = YahooFinance::get_historical_quotes_days(symbol, days_past)
      histJSON = hist.map { |e| {:id => e}}.to_json

      # The second way
      # Downloading as YahooFinance::HistoricalQuote object
      # If using this method, change the following in stocks.html.erb
      #   for each object, hq: hq.symbol, hq.date, hq.open, hq.high, hq.low
      #                        hq.close, hq.volume, hq.adjClose
      #
      # ****to_json has some weird output when using this method*****
      #
      #@hist = YahooFinance::get_HistoricalQuotes_days(ticker, days_past)
      #@histJSON = @hist.map { |e| {:id => e}}.to_json

      # Caching the historical data
      #cache(histJSON, symbol, true)
      
      { hist: histJSON }

    end

    # Download and cache the current quote for target stock
    def fetch_finance_curr(symbol)
      # Get new data
      quote = YahooFinance::get_standard_quotes(symbol)
      #cache(quote, symbol, false)

      { quotes: quote }

    end

    # Stores the results in the DB
    def cache(data, symbol, historical)
      # :status is an enum which identifies historical (0) or current(1) data
      if (historical)
        yhoo_cache = 
          FinanceCache.new(hist_data: data,
                           status: 0,
                           company_id: Company.find_by(symbol: symbol).id
                          )
        yhoo_cache.save
      else 
        yhoo_cache =
          FinanceCache.new(curr_data: data,
                           status: 1,
                           company_id: Company.find_by(symbol: symbol).id
                          )
        yhoo_cache.save
      end
    end

    # Checks cache for stored stock data
    def get_cached_data(symbol, historical)
      company = Company.find_by(symbol: symbol)
      type = historical ? 0 : 1
      cached = FinanceCache.where(company_id: company.id, :status => type)

      # Only keep historical data for a day, and current for 15 minutes
      exp_period = historical ? 1.day : 15.min
      if cached.created_at < Time.zone.now - exp_period
        cached.destory
        cached = nil
      end
    rescue
      return nil
    end
  end
end
