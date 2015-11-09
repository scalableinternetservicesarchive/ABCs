class CreateFinanceCaches < ActiveRecord::Migration
  def change
    create_table :finance_caches do |t|
      t.text :hist_data  
      t.text :curr_data  
      t.integer :category
      t.references :company, index: { unique: false }, foreign_key: true

      t.timestamps null: false
    end
  end
end
