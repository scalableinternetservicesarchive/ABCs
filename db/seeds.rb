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
puts 'Seeding companies'
CSV.foreach('db/csv/companies.csv') do |row|
  c = Company.new
  c.industry = row[6]
  c.name = row[1]
  c.sector = row[5]
  c.symbol = row[0]
  begin
    c.save
  rescue
    puts "Failed to save #{c.symbol}. It probably already exists in the DB"
  end
end
puts "There are now #{Company.count} rows in the Company table"

puts 'Seeding users'
aapl = Company.find_by(symbol: 'AAPL')
tsla = Company.find_by(symbol: 'TSLA')
fb = Company.find_by(symbol: 'FB')
# GOOGL is left for the perf testing tool to favorite

num_users_wanted = 2500
if User.count == 0
  (1..num_users_wanted).each do |i|
    u = User.new
    u.email = "test#{i}@test.com"
    u.password = 'password'
    u.password_confirmation = 'password'
    u.companys << aapl
    u.companys << tsla
    u.companys << fb
    u.save
    puts "Saved user #{i}" if i % 10 == 0
  end
  puts "Seeded #{User.count} users in the User table"
else
  puts "No need to seed users. #{User.count} already exist!"
end
