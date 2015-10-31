require 'analyzer'

# Test controller for demoing the sentiment analysis engine
class SentimentController < ApplicationController
  # rubocop:disable AbcSize, MethodLength
  # rubocop:disable CyclomaticComplexity, PerceivedComplexity
  def check
    # Get list of tickers for autocomplete
    @tickers = ticker_json(Company.all)
    return unless params['symbol']

    # Get cached symbol if possible
    @symbol = params['symbol'].upcase
    cached_result = get_cached_sentiment(@symbol)
    if cached_result
      @symbol_rating = cached_result.score
      @num_tweets = cached_result.num_tweets
      @results = [{ timestamp: cached_result.tweet_when,
                    author: cached_result.tweet_author,
                    text: cached_result.tweet_text }]
      return
    end

    # Get new data, store it and display it
    analyzer = Analyzer.new
    # rubocop:disable GlobalVars
    @tweets = $twitter.search('$' + @symbol + ' -rt',
                              result_type: 'mixed',
                              count: 20).take(100)
    # rubocop:enable GlobalVars
    @results = []
    total_points = 0
    tweet_map = {}
    @tweets.each do |tweet|
      res = analyzer.process(tweet.text)
      # Skip adding neutral
      next unless res
      factor = res.sentiment == ':)' ? 1 : -1
      score = factor * res.overall_probability
      total_points += score
      @results << res
      tweet_map[tweet] = score
    end
    @num_tweets = @results.length

    # if a bad ticker was entered or no tweets found, show a 404
    if @num_tweets == 0
      render file: 'public/404.html', status: :not_found, layout: false
      return
    end

    rating = total_points / @num_tweets
    @symbol_rating = rating * 100

    # Store the closest ("average") tweet in the db
    # set smallest_diff to 10 to promise we'll get a tweet
    smallest_diff = 10 # on a scale of -1 to 1
    closest = nil
    @tweets.each do |tweet|
      next if tweet_map[tweet].nil?
      diff = (rating - tweet_map[tweet]).abs
      if diff < smallest_diff
        smallest_diff = diff
        closest = tweet
      end
    end
    sent_cache =
      SentimentCache.new(score: @symbol_rating,
                         num_tweets: @num_tweets,
                         tweet_when: closest.created_at,
                         tweet_author: closest.user.screen_name,
                         tweet_text: closest.text,
                         company_id: Company.find_by(symbol: @symbol).id
                        )
    sent_cache.save
  end

  private

  def get_cached_sentiment(symbol)
    company = Company.find_by(symbol: symbol)
    cached = SentimentCache.find_by(company_id: company.id)

    # Only keep sentiments cached for a day
    if cached.created_at < Time.zone.now.beginning_of_day
      cached.destroy
      cached = nil
    end

    return cached
  rescue
    return nil
  end

  def ticker_json(companies)
    list = companies.map(&:symbol)
    list.to_json
  end

  def sent_params
    params.require(:tweet)
  end
end
