class MarketChirpController < ApplicationController
  def index
    if !params[:search].blank?
      @searching = true
      @query = params[:search].to_s
      num = 100
      # omit retweets with '-rt', result type: mixed for popular and recent
      @tweets = $twitter.search(@query + ' -rt', result_type: 'mixed', count: 20).take(num)
    end
  end

end
