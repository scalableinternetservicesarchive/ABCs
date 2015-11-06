class CreateFinanceCache < ActiveRecord::Migration
  def change
    create_table :finance_caches do |t|
      t.text :hist_data
      t.text :curr_data
      t.integer :status, default: 0
      t.references :company, index: {:unique=>true}, foreign_key: true

      t.timestamps null: false
    end
  end
end
