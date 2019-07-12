require "application_system_test_case"

class DoubtAnswersTest < ApplicationSystemTestCase
  setup do
    @doubt_answer = doubt_answers(:one)
  end

  test "visiting the index" do
    visit doubt_answers_url
    assert_selector "h1", text: "Doubt Answers"
  end

  test "creating a Doubt answer" do
    visit doubt_answers_url
    click_on "New Doubt Answer"

    click_on "Create Doubt answer"

    assert_text "Doubt answer was successfully created"
    click_on "Back"
  end

  test "updating a Doubt answer" do
    visit doubt_answers_url
    click_on "Edit", match: :first

    click_on "Update Doubt answer"

    assert_text "Doubt answer was successfully updated"
    click_on "Back"
  end

  test "destroying a Doubt answer" do
    visit doubt_answers_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Doubt answer was successfully destroyed"
  end
end
