require "application_system_test_case"

class UserAnalyticsTest < ApplicationSystemTestCase
  setup do
    @user_analytic = user_analytics(:one)
  end

  test "visiting the index" do
    visit user_analytics_url
    assert_selector "h1", text: "User Analytics"
  end

  test "creating a User analytic" do
    visit user_analytics_url
    click_on "New User Analytic"

    click_on "Create User analytic"

    assert_text "User analytic was successfully created"
    click_on "Back"
  end

  test "updating a User analytic" do
    visit user_analytics_url
    click_on "Edit", match: :first

    click_on "Update User analytic"

    assert_text "User analytic was successfully updated"
    click_on "Back"
  end

  test "destroying a User analytic" do
    visit user_analytics_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "User analytic was successfully destroyed"
  end
end
