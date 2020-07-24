require 'test_helper'

class UserRegisterControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get user_register_new_url
    assert_response :success
  end

  test "should get create" do
    get user_register_create_url
    assert_response :success
  end

end
