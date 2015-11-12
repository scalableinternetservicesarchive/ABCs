class CreateFavoriteCompanies < ActiveRecord::Migration
  def change
    create_table :favorite_companies do |t|
      t.belongs_to    :user, index: true
      t.belongs_to    :company, index: true
      t.boolean       :active, null: false, default: true
      t.timestamps null: false
    end
  end
end
