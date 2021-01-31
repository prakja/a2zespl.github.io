require 'test_helper'

class LoginPageTest < ActionDispatch::IntegrationTest
  test "can see login page" do 
    get "/admin/login"
    assert_select "title", 'Login | NEETprep Admin'
  end
end
