class Company < ActiveRecord::Base
  has_many :favorite_companys
  has_many :users, through: :favorite_companys
end
