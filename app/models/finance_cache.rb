#This model caches yahoo-finance data
class FinanceCache < ActiveRecord::Base
  belongs_to :company
  enum status: [ :historic, :current ]
end
