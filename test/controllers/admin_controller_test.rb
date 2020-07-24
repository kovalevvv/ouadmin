require 'test_helper'

class AdminControllerTest < ActionDispatch::IntegrationTest
  test "should get dashboard" do
    get admin_dashboard_url
    assert_response :success
  end

  test "should get search" do
    get admin_search_url
    assert_response :success
  end

end
