require 'sentiment_analyzer.rb'
require 'test_helper'

class SentimentAnalyzerTest < ActiveSupport::TestCase
  def setup
    # Empty the cache
    SentimentCache.delete_all
  end

  test 'Check caching and twitter feed' do
    # Cache miss
    start_miss = Time.now
    sent_miss = SentimentAnalyzer.get_results('AAPL')
    end_miss = Time.now
    time_miss = end_miss - start_miss

    # Cache hit
    start_hit = Time.now
    sent_hit = SentimentAnalyzer.get_results('AAPL')
    end_hit = Time.now
    time_hit = end_hit - start_hit

    # Compare results
    # Ensure the cached rating is basically the same as the fetched rating,
    # allowing a change of less than 1%
    rating_diff = sent_hit[:symbol_rating].to_f.round(3) -
                  sent_miss[:symbol_rating].to_f.round(3)
    diff_percentage = rating_diff / sent_miss[:symbol_rating].to_f.round(3)
    assert(diff_percentage < 0.01,
           'Symbol ratings differ between fresh and cached')
    assert_equal(sent_hit[:num_tweets], sent_miss[:num_tweets],
                 'Number of tweets differ between fresh and cached')
    assert(time_hit < time_miss, 'Cache hit took as long as cache miss')
  end

  test 'Check cache expiration' do
    # Cache miss
    start_miss = Time.now
    SentimentAnalyzer.get_results('AAPL')
    end_miss = Time.now
    time_miss = end_miss - start_miss

    # Cache hit
    start_hit = Time.now
    SentimentAnalyzer.get_results('AAPL')
    end_hit = Time.now
    time_hit = end_hit - start_hit

    # Cache expired
    # First, expire the cache
    company = Company.find_by(symbol: 'AAPL')
    cached = SentimentCache.find_by(company_id: company.id)
    cached.created_at = cached.created_at - 1.day - 1.hour
    cached.save

    # Second, make sure this request takes longer than the cache hit
    start_expired = Time.now
    SentimentAnalyzer.get_results('AAPL')
    end_expired = Time.now
    time_expired = end_expired - start_expired

    # Compare results
    assert(time_hit < time_miss, 'Cache doesn\'t take less time')
    assert(time_hit < time_expired, 'Cache didn\'t expire')
    assert(time_expired - time_miss < time_expired - time_hit,
           'Expired cache timing is closer to cache hit timing than cache miss'\
           ' timing.  This probably means that something is wrong, although'\
           ' that is not necessarily the case.')
  end

  test 'Ensure exception thrown on bad ticker' do
    assert_raises ArgumentError do
      SentimentAnalyzer.get_results('ILOVEMARKETCHIRP')
    end
  end
end
