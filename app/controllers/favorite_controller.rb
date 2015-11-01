class FavoriteController < ApplicationController
  def favorite
    return unless params['symbol']
    @results = Company.all
    @symbol = params['symbol'].upcase
  end

  def create_favorite
    @user_id = params['user_id']
    @company_id = params['company_id']

    u = User.find(@user_id)
    c = Company.find(@company_id)

    # favorite_company = FavoriteCompany.new
    # favorite_company.user = u
    # favorite_company.company = c
    # favorite_company.save

    if !u.companys.exists?(@company_id)
      u.companys << c
    else
      @message = 'already exists'
    end
  end

  def ticker_json(companies)
    list = companies.map(&:symbol)
    list.to_json
  end
end
