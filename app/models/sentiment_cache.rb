# This model caches sentiment analysis data
class SentimentCache < ActiveRecord::Base
  belongs_to :company
end
