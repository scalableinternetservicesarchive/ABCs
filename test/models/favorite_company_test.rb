require 'test_helper'

class FavoriteCompanyTest < ActiveSupport::TestCase
  test 'create_favorite_company_association' do
    user = User.find_by(email: 'user@example.com')
    company = Company.find_by(symbol: 'AAPL')

    user.companys << company

    association = user.favorite_companys.find_by_company_id(company.id)
    # check if association exists
    assert_not_nil(user.favorite_companys.find_by_company_id(company.id),
      'Company was not associtaed to user, search by id returned null')
    # verify association set to active by default
    assert(association.active,
      'New company association was not set to active by default')

    # verify new associations can be made
    company = Company.find_by(symbol: 'GOOGL')
    user.companys << company

    assert(user.favorite_companys.count == 2,
      'Second favorite not added for user')
  end

  test 'updating_favorite_company_associations' do
    user = User.find_by(email: 'user2@example.com')
    company = Company.find_by(symbol: 'GOOGL')

    user.companys << company

    # update association to inactive
    user.favorite_companys.find_by_company_id(company.id).update(:active => false)
    association = user.favorite_companys.find_by_company_id(company.id)

    assert(!association.active,
      'Company association active field not updated to false')

    user.favorite_companys.find_by_company_id(company.id).update(:active => true)
    association = user.favorite_companys.find_by_company_id(company.id)

    assert(association.active,
      'Company association active field not updated to true')
  end
end
