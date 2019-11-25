require "application_system_test_case"

class GroupChatsTest < ApplicationSystemTestCase
  setup do
    @group_chat = group_chats(:one)
  end

  test "visiting the index" do
    visit group_chats_url
    assert_selector "h1", text: "Group Chats"
  end

  test "creating a Group chat" do
    visit group_chats_url
    click_on "New Group Chat"

    click_on "Create Group chat"

    assert_text "Group chat was successfully created"
    click_on "Back"
  end

  test "updating a Group chat" do
    visit group_chats_url
    click_on "Edit", match: :first

    click_on "Update Group chat"

    assert_text "Group chat was successfully updated"
    click_on "Back"
  end

  test "destroying a Group chat" do
    visit group_chats_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Group chat was successfully destroyed"
  end
end
