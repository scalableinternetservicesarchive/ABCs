require 'yahoo_finance.rb'
require 'test_helper'

class YahooFinanceTest < ActiveSupport::TestCase
  test 'Check caching stock data' do
    # Cache miss
    start_miss = Time.now
    finance_miss = Finance.get_quotes('AAPL', 0)
    end_miss = Time.now
    time_miss = end_miss - start_miss

    # Cache hit
    start_hit = Time.now
    finance_hit = Finance.get_quotes('AAPL', 0)
    end_hit = Time.now
    time_hit = end_hit - start_hit

    # Compare quotes
    assert_equal(finance_hit['name'], finance_miss['name'],
                 'Symbol names differ between fresh and cached')
    assert_equal(finance_hit['open'], finance_miss['open'], 
                 'Opening prices differ between fresh and cached')
    assert(time_hit < time_miss, 'Cache hit no faster than cache miss')
  end

  test 'Check only one record of each type for a company' do
    # Querying for AAPL twice to check for multiple cache attempts
    Finance.get_quotes('AAPL', 0)
    Finance.get_quotes('AAPL', 0)
    company = Company.find_by(symbol: 'AAPL')
    count_hist_entries = FinanceCache.where(company_id: company.id,
                                            category: 0).count
    count_curr_entries = FinanceCache.where(company_id: company.id,
                                            category: 1).count
    assert_equal(1, count_hist_entries, 
                 'Cache is adding too many historical records or not enough.')
    assert_equal(1, count_curr_entries, 
                 'Cache is adding too many current records or not enough.')
  end
  
  test 'Check cache expiration' do
    # Cache miss
    start_miss = Time.now
    Finance.get_quotes('AAPL', 0)
    end_miss = Time.now
    time_miss = end_miss - start_miss

    # Cache hit
    start_hit = Time.now
    Finance.get_quotes('AAPL', 0)
    end_hit = Time.now
    time_hit = end_hit - start_hit

    # Cache expired
    # First, expire the caches for both curr and hist records
    company = Company.find_by(symbol: 'AAPL')
    cached_hist = FinanceCache.find_by(company_id: company.id, category: 1)
    cached_curr = FinanceCache.find_by(company_id: company.id, category: 0)
    assert_not_nil(cached_hist, 'Couldn\'t find cached history quotes.')
    assert_not_nil(cached_curr, 'Couldn\'t find cached current quotes.')
    cached_hist.save
    cached_curr.save
    cached_hist.created_at = cached_hist.created_at - 1.day - 1.hour
    cached_curr.created_at = cached_curr.created_at - 30*60 # 30 minutes

    # Second, make sure this request takes longer than a cache hit
    start_expired = Time.now
    Finance.get_quotes('AAPL', 0)
    end_expired = Time.now
    time_expired = end_expired - start_expired

    # Compare results
    assert(time_hit < time_miss, 'Cache doesn\'t take less time')
    assert(time_hit < time_expired, 'Cache didn\'t expire')
    assert(time_expired - time_miss < time_expired - time_hit,
           'Expired cache timing is closer to cache hit time than cache miss'\
           'timing. This probably means that something is wrong, although'\
           ' that is not necessarily the case.')
  end

  test 'Ensure exception thrown on bad ticker' do
    # Test on bad ticker when getting historical quote
    assert_raises ArgumentError do
      Finance.get_quotes('$$$$$$$$', true)
    end
    # Test on bad ticker when getting current quote
    assert_raises ArgumentError do
      Finance.get_quotes('$$$$$$$$', false)
    end
  end
end
