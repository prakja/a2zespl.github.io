require 'test_helper'

class CourseDetailsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @course_detail = course_details(:one)
  end

  test "should get index" do
    get course_details_url
    assert_response :success
  end

  test "should get new" do
    get new_course_detail_url
    assert_response :success
  end

  test "should create course_detail" do
    assert_difference('CourseDetail.count') do
      post course_details_url, params: { course_detail: {  } }
    end

    assert_redirected_to course_detail_url(CourseDetail.last)
  end

  test "should show course_detail" do
    get course_detail_url(@course_detail)
    assert_response :success
  end

  test "should get edit" do
    get edit_course_detail_url(@course_detail)
    assert_response :success
  end

  test "should update course_detail" do
    patch course_detail_url(@course_detail), params: { course_detail: {  } }
    assert_redirected_to course_detail_url(@course_detail)
  end

  test "should destroy course_detail" do
    assert_difference('CourseDetail.count', -1) do
      delete course_detail_url(@course_detail)
    end

    assert_redirected_to course_details_url
  end
end
