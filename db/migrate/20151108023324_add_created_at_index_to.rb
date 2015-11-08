class AddCreatedAtIndexTo < ActiveRecord::Migration
  def change
    add_index :sentiment_caches, :created_at, order: {created_at: :desc}
  end
end
