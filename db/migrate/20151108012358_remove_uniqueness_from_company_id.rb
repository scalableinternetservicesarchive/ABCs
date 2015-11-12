class RemoveUniquenessFromCompanyId < ActiveRecord::Migration
  def change
    add_index :sentiment_caches, :company_id, {name: 'index_sentiment_caches_on_company_id-non-unique', using: :btree}
    remove_index :sentiment_caches, name: :index_sentiment_caches_on_company_id
  end
end
