require 'test_helper'

class MarketChirpControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  test 'should get index' do
    get :index
    assert_response :success
  end
end
