# This file should contain all the record creation needed to seed the
# database with its default values.
# The data can then be loaded with the rake db:seed
# (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require 'csv'

# Load up the list of all companies and their name, symbol, sector, industry
# Old header "Symbol","Name","LastSale","MarketCap","IPOyear","Sector",
#            "industry","Summary Quote",
# Column index mapping:
#  0: Symbol
#  1: Name
#  2: LastSale
#  3: MarketCap
#  4: IPOyear
#  5: Sector
#  6: industry
#  7: Summary Quote
CSV.foreach('db/csv/companies.csv') do |row|
  c = Company.new
  c.industry = row[6]
  c.name = row[1]
  c.sector = row[5]
  c.symbol = row[0]
  c.save
end
puts "There are now #{Company.count} rows in the Company table"
