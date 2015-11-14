require 'analyzer'

# Analyze a given symbol's tweets to get a general feeling towards the company
class SentimentAnalyzer
  # Returns {symbol_rating: number, num_tweets: number, results: [json objs]}
  # Looks up symbol in cache. If in cache, return value if not expired.
  # Otherwise, fetch the tweets and process them.
  def self.get_results(symbol)
    symbol.upcase!
    if Company.find_by(symbol: symbol).nil?
      fail(ArgumentError,
           "#{symbol} is an invalid symbol! Not found in company database")
    end
    #cached_result = get_cached_sentiment(symbol)
    #return fetch_sentiment(symbol) unless cached_result
    #{ symbol_rating: cached_result.score,
    #  num_tweets: cached_result.num_tweets,
    #  results: [{ timestamp: cached_result.tweet_when,
    #              author: cached_result.tweet_author,
    #              text: cached_result.tweet_text }] }
    Rails.cache.fetch(symbol, expires_in: 15.minutes) do
      fetch_sentiment(symbol)
    end
    Rails.cache.read symbol
  end

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
      rating, num_tweets, closest = analyze_tweets(tweets)
      symbol_rating = rating * 100

      # Cache the results
      cache(symbol_rating, num_tweets, closest, symbol)

      { symbol_rating: symbol_rating,
        num_tweets: num_tweets,
        results: [{ timestamp: closest.created_at,
                    author: closest.user.screen_name,
                    text: closest.text }] }
    end

    # Store the analysis results in the DB
    def cache(score, num_tweets, avg_tweet, symbol)
      sent_cache =
        SentimentCache.new(score: score,
                           num_tweets: num_tweets,
                           tweet_when: avg_tweet.created_at,
                           tweet_author: avg_tweet.user.screen_name,
                           tweet_text: remove_emoji(avg_tweet.text),
                           company_id: Company.find_by(symbol: symbol).id
                          )
      sent_cache.save
    rescue ActiveRecord::RecordNotUnique => e
      # Catch race condition where multiple users try to cache the same symbol
      puts e.message
    end

    # Analyze tweets
    # rubocop:disable AbcSize
    def analyze_tweets(tweets)
      analyzer = Analyzer.new
      num_results = 0
      total_points = 0
      tweet_map = {}
      tweets.each do |tweet|
        res = analyzer.process(tweet.text)
        # Skip adding neutral
        next unless res
        factor = res.sentiment == ':)' ? 1 : -1
        score = factor * res.overall_probability
        total_points += score
        num_results += 1
        tweet_map[tweet] = score
      end

      # if a bad ticker was entered or no tweets found, error
      fail ArgumentError, "No data found for #{symbol}" if num_results == 0

      rating = total_points / num_results
      # Get the closest ("average") tweet
      [rating, num_results, get_closest(tweets, tweet_map, rating)]
    end
    # rubocop:enable AbcSize

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

    # Remove emoji because the DB doesn't like them
    def remove_emoji(tweet)
      emoji_regex = /[\u{203C}\u{2049}\u{20E3}\u{2122}\u{2139}\u{2194}-\u{2199}\u{21A9}-\u{21AA}\u{231A}-\u{231B}\u{23E9}-\u{23EC}\u{23F0}\u{23F3}\u{24C2}\u{25AA}-\u{25AB}\u{25B6}\u{25C0}\u{25FB}-\u{25FE}\u{2600}-\u{2601}\u{260E}\u{2611}\u{2614}-\u{2615}\u{261D}\u{263A}\u{2648}-\u{2653}\u{2660}\u{2663}\u{2665}-\u{2666}\u{2668}\u{267B}\u{267F}\u{2693}\u{26A0}-\u{26A1}\u{26AA}-\u{26AB}\u{26BD}-\u{26BE}\u{26C4}-\u{26C5}\u{26CE}\u{26D4}\u{26EA}\u{26F2}-\u{26F3}\u{26F5}\u{26FA}\u{26FD}\u{2702}\u{2705}\u{2708}-\u{270C}\u{270F}\u{2712}\u{2714}\u{2716}\u{2728}\u{2733}-\u{2734}\u{2744}\u{2747}\u{274C}\u{274E}\u{2753}-\u{2755}\u{2757}\u{2764}\u{2795}-\u{2797}\u{27A1}\u{27B0}\u{2934}-\u{2935}\u{2B05}-\u{2B07}\u{2B1B}-\u{2B1C}\u{2B50}\u{2B55}\u{3030}\u{303D}\u{3297}\u{3299}\u{1F004}\u{1F0CF}\u{1F170}-\u{1F171}\u{1F17E}-\u{1F17F}\u{1F18E}\u{1F191}-\u{1F19A}\u{1F1E7}-\u{1F1EC}\u{1F1EE}-\u{1F1F0}\u{1F1F3}\u{1F1F5}\u{1F1F7}-\u{1F1FA}\u{1F201}-\u{1F202}\u{1F21A}\u{1F22F}\u{1F232}-\u{1F23A}\u{1F250}-\u{1F251}\u{1F300}-\u{1F320}\u{1F330}-\u{1F335}\u{1F337}-\u{1F37C}\u{1F380}-\u{1F393}\u{1F3A0}-\u{1F3C4}\u{1F3C6}-\u{1F3CA}\u{1F3E0}-\u{1F3F0}\u{1F400}-\u{1F43E}\u{1F440}\u{1F442}-\u{1F4F7}\u{1F4F9}-\u{1F4FC}\u{1F500}-\u{1F507}\u{1F509}-\u{1F53D}\u{1F550}-\u{1F567}\u{1F5FB}-\u{1F640}\u{1F645}-\u{1F64F}\u{1F680}-\u{1F68A}]/
      tweet.gsub emoji_regex, ''
    end

    # Check cache for stored sentiment values
    def get_cached_sentiment(symbol)
      company = Company.find_by(symbol: symbol)
      # Get the most recent cache value
      cached = SentimentCache.where(company_id: company.id)
               .order('created_at DESC')
               .first

      # Only count sentiments from the past day
      cached = nil if cached.created_at < Time.zone.now - 1.day
      return cached
    rescue
      return nil
    end
  end
end
