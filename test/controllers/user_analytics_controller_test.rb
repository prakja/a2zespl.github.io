require 'test_helper'

class UserAnalyticsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user_analytic = user_analytics(:one)
  end

  test "should get index" do
    get user_analytics_url
    assert_response :success
  end

  test "should get new" do
    get new_user_analytic_url
    assert_response :success
  end

  test "should create user_analytic" do
    assert_difference('UserAnalytic.count') do
      post user_analytics_url, params: { user_analytic: {  } }
    end

    assert_redirected_to user_analytic_url(UserAnalytic.last)
  end

  test "should show user_analytic" do
    get user_analytic_url(@user_analytic)
    assert_response :success
  end

  test "should get edit" do
    get edit_user_analytic_url(@user_analytic)
    assert_response :success
  end

  test "should update user_analytic" do
    patch user_analytic_url(@user_analytic), params: { user_analytic: {  } }
    assert_redirected_to user_analytic_url(@user_analytic)
  end

  test "should destroy user_analytic" do
    assert_difference('UserAnalytic.count', -1) do
      delete user_analytic_url(@user_analytic)
    end

    assert_redirected_to user_analytics_url
  end
end
