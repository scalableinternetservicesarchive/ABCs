# This controller runs the API routes for front-end code
class ApiController < ApplicationController
  def symjson
    render json: ticker_json(Company.all)
  end

  private

  def ticker_json(companies)
    list = companies.map(&:symbol)
    list.to_json
  end
end
