class CreateSentimentCaches < ActiveRecord::Migration
  def change
    create_table :sentiment_caches do |t|
      t.timestamp :tweet_when
      t.decimal :score, precision: 6, scale: 3
      t.string :tweet_text
      t.string :tweet_author
      t.integer :num_tweets
      t.references :company, index: {:unique=>true}, foreign_key: true

      t.timestamps null: false
    end
  end
end
