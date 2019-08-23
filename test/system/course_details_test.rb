require "application_system_test_case"

class CourseDetailsTest < ApplicationSystemTestCase
  setup do
    @course_detail = course_details(:one)
  end

  test "visiting the index" do
    visit course_details_url
    assert_selector "h1", text: "Course Details"
  end

  test "creating a Course detail" do
    visit course_details_url
    click_on "New Course Detail"

    click_on "Create Course detail"

    assert_text "Course detail was successfully created"
    click_on "Back"
  end

  test "updating a Course detail" do
    visit course_details_url
    click_on "Edit", match: :first

    click_on "Update Course detail"

    assert_text "Course detail was successfully updated"
    click_on "Back"
  end

  test "destroying a Course detail" do
    visit course_details_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Course detail was successfully destroyed"
  end
end
