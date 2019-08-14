require "application_system_test_case"

class UserDoubtCountsTest < ApplicationSystemTestCase
  setup do
    @user_doubt_count = user_doubt_counts(:one)
  end

  test "visiting the index" do
    visit user_doubt_counts_url
    assert_selector "h1", text: "User Doubt Counts"
  end

  test "creating a User doubt count" do
    visit user_doubt_counts_url
    click_on "New User Doubt Count"

    click_on "Create User doubt count"

    assert_text "User doubt count was successfully created"
    click_on "Back"
  end

  test "updating a User doubt count" do
    visit user_doubt_counts_url
    click_on "Edit", match: :first

    click_on "Update User doubt count"

    assert_text "User doubt count was successfully updated"
    click_on "Back"
  end

  test "destroying a User doubt count" do
    visit user_doubt_counts_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "User doubt count was successfully destroyed"
  end
end
