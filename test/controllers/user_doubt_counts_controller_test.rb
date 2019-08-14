require 'test_helper'

class UserDoubtCountsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user_doubt_count = user_doubt_counts(:one)
  end

  test "should get index" do
    get user_doubt_counts_url
    assert_response :success
  end

  test "should get new" do
    get new_user_doubt_count_url
    assert_response :success
  end

  test "should create user_doubt_count" do
    assert_difference('UserDoubtCount.count') do
      post user_doubt_counts_url, params: { user_doubt_count: {  } }
    end

    assert_redirected_to user_doubt_count_url(UserDoubtCount.last)
  end

  test "should show user_doubt_count" do
    get user_doubt_count_url(@user_doubt_count)
    assert_response :success
  end

  test "should get edit" do
    get edit_user_doubt_count_url(@user_doubt_count)
    assert_response :success
  end

  test "should update user_doubt_count" do
    patch user_doubt_count_url(@user_doubt_count), params: { user_doubt_count: {  } }
    assert_redirected_to user_doubt_count_url(@user_doubt_count)
  end

  test "should destroy user_doubt_count" do
    assert_difference('UserDoubtCount.count', -1) do
      delete user_doubt_count_url(@user_doubt_count)
    end

    assert_redirected_to user_doubt_counts_url
  end
end
