require 'test_helper'

class ApiControllerTest < ActionController::TestCase
  test 'should get api/symbols/json' do
    get :symjson
    assert_response :success
    assert response.headers['Content-Type'].include? 'application/json'
  end
end
