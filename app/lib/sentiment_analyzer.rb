require 'analyzer'

# Analyze a given symbol's tweets to get a general feeling towards the company
class SentimentAnalyzer
  # Returns {symbol_rating: number, num_tweets: number, results: [json objs]}
  # Looks up symbol in cache. If in cache, return value if not expired.
  # Otherwise, fetch the tweets and process them.
  # rubocop:disable MethodLength
  def self.get_results(symbol)
    symbol.upcase!
    if Company.find_by(symbol: symbol).nil?
      fail(ArgumentError,
           "#{symbol} is an invalid symbol! Not found in company database")
    end
    cached_result = get_cached_sentiment(symbol)
    return fetch_sentiment(symbol) unless cached_result
    { symbol_rating: cached_result.score,
      num_tweets: cached_result.num_tweets,
      results: [{ timestamp: cached_result.tweet_when,
                  author: cached_result.tweet_author,
                  text: cached_result.tweet_text }] }
  end
  # rubocop:enable MethodLength

  class << self
    private

    # Download the tweets, analyze them, cache and return the results.
    def fetch_sentiment(symbol)
      # Get new data
      # rubocop:disable GlobalVars
      tweets = $twitter.search('$' + symbol + ' -rt',
                               result_type: 'mixed',
                               count: 20).take(100)
      # rubocop:enable GlobalVars

      # Analyze the tweets
      results, rating, num_tweets, closest = analyze_tweets(tweets)
      symbol_rating = rating * 100

      # Cache the results
      cache(symbol_rating, num_tweets, closest, symbol)

      { symbol_rating: symbol_rating,
        num_tweets: num_tweets,
        results: results }
    end

    # Store the analysis results in the DB
    def cache(score, num_tweets, avg_tweet, symbol)
      sent_cache =
        SentimentCache.new(score: score,
                           num_tweets: num_tweets,
                           tweet_when: avg_tweet.created_at,
                           tweet_author: avg_tweet.user.screen_name,
                           tweet_text: avg_tweet.text,
                           company_id: Company.find_by(symbol: symbol).id
                          )
      sent_cache.save
    rescue ActiveRecord::RecordNotUnique => e
      # Catch race condition where multiple users try to cache the same symbol
      puts e.message
    end

    # Analyze tweets
    # rubocop:disable MethodLength, AbcSize
    def analyze_tweets(tweets)
      analyzer = Analyzer.new
      results = []
      total_points = 0
      tweet_map = {}
      tweets.each do |tweet|
        res = analyzer.process(tweet.text)
        # Skip adding neutral
        next unless res
        factor = res.sentiment == ':)' ? 1 : -1
        score = factor * res.overall_probability
        total_points += score
        results << res
        tweet_map[tweet] = score
      end

      # if a bad ticker was entered or no tweets found, error
      fail ArgumentError, "No data found for #{symbol}" if results.length == 0

      rating = total_points / results.length
      # Get the closest ("average") tweet
      [results, rating, results.length, get_closest(tweets, tweet_map, rating)]
    end
    # rubocop:enable MethodLength, AbcSize

    # rubocop:disable MethodLength
    def get_closest(tweets, tweet_map, rating)
      # set smallest_diff to 10 to promise we'll get a tweet
      smallest_diff = 10 # on a scale of -1 to 1
      closest = nil
      tweets.each do |tweet|
        next if tweet_map[tweet].nil?
        diff = (rating - tweet_map[tweet]).abs
        if diff < smallest_diff
          smallest_diff = diff
          closest = tweet
        end
      end
      closest
    end
    # rubocop:enable MethodLength

    # Check cache for stored sentiment values
    def get_cached_sentiment(symbol)
      company = Company.find_by(symbol: symbol)
      cached = SentimentCache.find_by(company_id: company.id)

      # Only keep sentiments cached for a day
      if cached.created_at < Time.zone.now - 1.day
        cached.destroy
        cached = nil
      end

      return cached
    rescue
      return nil
    end
  end
end
