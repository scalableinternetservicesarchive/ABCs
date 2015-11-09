class FinanceCache < ActiveRecord::Base
  belongs_to :company
  enum category: [ :historic, :current ]
end
