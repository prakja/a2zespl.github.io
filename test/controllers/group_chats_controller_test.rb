require 'test_helper'

class GroupChatsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @group_chat = group_chats(:one)
  end

  test "should get index" do
    get group_chats_url
    assert_response :success
  end

  test "should get new" do
    get new_group_chat_url
    assert_response :success
  end

  test "should create group_chat" do
    assert_difference('GroupChat.count') do
      post group_chats_url, params: { group_chat: {  } }
    end

    assert_redirected_to group_chat_url(GroupChat.last)
  end

  test "should show group_chat" do
    get group_chat_url(@group_chat)
    assert_response :success
  end

  test "should get edit" do
    get edit_group_chat_url(@group_chat)
    assert_response :success
  end

  test "should update group_chat" do
    patch group_chat_url(@group_chat), params: { group_chat: {  } }
    assert_redirected_to group_chat_url(@group_chat)
  end

  test "should destroy group_chat" do
    assert_difference('GroupChat.count', -1) do
      delete group_chat_url(@group_chat)
    end

    assert_redirected_to group_chats_url
  end
end
