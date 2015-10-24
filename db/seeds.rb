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
CSV.foreach('db/csv/companies.csv',
            headers: 'true',
            header_converters: 'symbol') do |row|
              c = Company.new
              c.industry = row[:industry]
              c.name = row[:name]
              c.sector = row[:sector]
              c.symbol = row[:symbol]
              c.save
            end
puts "There are now #{Company.count} rows in the Company table"
