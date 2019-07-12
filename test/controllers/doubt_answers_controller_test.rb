require 'test_helper'

class DoubtAnswersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @doubt_answer = doubt_answers(:one)
  end

  test "should get index" do
    get doubt_answers_url
    assert_response :success
  end

  test "should get new" do
    get new_doubt_answer_url
    assert_response :success
  end

  test "should create doubt_answer" do
    assert_difference('DoubtAnswer.count') do
      post doubt_answers_url, params: { doubt_answer: {  } }
    end

    assert_redirected_to doubt_answer_url(DoubtAnswer.last)
  end

  test "should show doubt_answer" do
    get doubt_answer_url(@doubt_answer)
    assert_response :success
  end

  test "should get edit" do
    get edit_doubt_answer_url(@doubt_answer)
    assert_response :success
  end

  test "should update doubt_answer" do
    patch doubt_answer_url(@doubt_answer), params: { doubt_answer: {  } }
    assert_redirected_to doubt_answer_url(@doubt_answer)
  end

  test "should destroy doubt_answer" do
    assert_difference('DoubtAnswer.count', -1) do
      delete doubt_answer_url(@doubt_answer)
    end

    assert_redirected_to doubt_answers_url
  end
end
