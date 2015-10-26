class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :symbol, limit: 5
      t.string :name
      t.string :sector
      t.string :industry

      t.timestamps null: false
    end
    add_index :companies, :symbol, unique: true
  end
end
