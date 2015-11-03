class FavoriteController < ApplicationController
  def favorite
    return unless current_user
    # get IDs of companies that are currently favorited
    user_favorite_active = current_user.favorite_companys.where(active: true).map(&:company_id)
    # Set the current user companies to the active ones
    @user_companies = current_user.companys.where(id: user_favorite_active)


    return unless params['symbol']
    query = params['symbol'].upcase
    @results = Company.where("symbol like :prefix", prefix: "%#{query}%")

  end

  def create_favorite
    @company_id = params['company_id']

    c = Company.find(@company_id)

    if !current_user.companys.exists?(@company_id)
      current_user.companys << c
    else
      current_user.favorite_companys.find_by_company_id(@company_id).update(:active => true)
      @message = 'already exists, enabling favorite again'
    end
  end


  def remove_favorite
    @company_id = params['company_id']
    current_user.favorite_companys.find_by_company_id(@company_id).update(:active => false)
    @message = 'Removed from favorites'
  end


  def ticker_json(companies)
    list = companies.map(&:symbol)
    list.to_json
  end
end
