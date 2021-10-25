class CustomerIssuesController < ApplicationController
  def pending_stats
    authenticate_admin_user!

    @botany_question_two_days = CustomerIssue.two_days_pending('botany_question')
    @botany_question_five_days = CustomerIssue.five_days_pending('botany_question')
    @botany_question_seven_days = CustomerIssue.seven_days_pending('botany_question')

    @chemistry_question_two_days = CustomerIssue.two_days_pending('chemistry_question')
    @chemistry_question_five_days = CustomerIssue.five_days_pending('chemistry_question')
    @chemistry_question_seven_days = CustomerIssue.seven_days_pending('chemistry_question')

    @physics_question_two_days = CustomerIssue.two_days_pending('physics_question')
    @physics_question_five_days = CustomerIssue.five_days_pending('physics_question')
    @physics_question_seven_days = CustomerIssue.seven_days_pending('physics_question')

    @zoology_question_two_days = CustomerIssue.two_days_pending('zoology_question')
    @zoology_question_five_days = CustomerIssue.five_days_pending('zoology_question')
    @zoology_question_seven_days = CustomerIssue.seven_days_pending('zoology_question')

    @physics_test_two_days = CustomerIssue.two_days_pending('physics_test')
    @physics_test_five_days = CustomerIssue.five_days_pending('physics_test')
    @physics_test_seven_days = CustomerIssue.seven_days_pending('physics_test')

    @chemistry_test_two_days = CustomerIssue.two_days_pending('chemistry_test')
    @chemistry_test_five_days = CustomerIssue.five_days_pending('chemistry_test')
    @chemistry_test_seven_days = CustomerIssue.seven_days_pending('chemistry_test')

    @biology_test_two_days = CustomerIssue.two_days_pending('biology_test')
    @biology_test_five_days = CustomerIssue.five_days_pending('biology_test')
    @biology_test_seven_days = CustomerIssue.seven_days_pending('biology_test')

    @zoology_test_two_days = CustomerIssue.two_days_pending('zoology_test')
    @zoology_test_five_days = CustomerIssue.five_days_pending('zoology_test')
    @zoology_test_seven_days = CustomerIssue.seven_days_pending('zoology_test')

    @botany_test_two_days = CustomerIssue.two_days_pending('botany_test')
    @botany_test_five_days = CustomerIssue.five_days_pending('botany_test')
    @botany_test_seven_days = CustomerIssue.seven_days_pending('botany_test')

    @botany_video_two_days = CustomerIssue.two_days_pending('botany_video')
    @botany_video_five_days = CustomerIssue.five_days_pending('botany_video')
    @botany_video_seven_days = CustomerIssue.seven_days_pending('botany_video')

    @chemistry_video_two_days = CustomerIssue.two_days_pending('chemistry_video')
    @chemistry_video_five_days = CustomerIssue.five_days_pending('chemistry_video')
    @chemistry_video_seven_days = CustomerIssue.seven_days_pending('chemistry_video')

    @physics_video_two_days = CustomerIssue.two_days_pending('physics_video')
    @physics_video_five_days = CustomerIssue.five_days_pending('physics_video')
    @physics_video_seven_days = CustomerIssue.seven_days_pending('physics_video')

    @zoology_video_two_days = CustomerIssue.two_days_pending('zoology_video')
    @zoology_video_five_days = CustomerIssue.five_days_pending('zoology_video')
    @zoology_video_seven_days = CustomerIssue.seven_days_pending('zoology_video')

    @masterclass_question_two_days = CustomerIssue.two_days_pending('masterclass_question')
    @masterclass_question_five_days = CustomerIssue.five_days_pending('masterclass_question')
    @masterclass_question_seven_days = CustomerIssue.seven_days_pending('masterclass_question')

    @masterclass_test_two_days = CustomerIssue.two_days_pending('masterclass_test')
    @masterclass_test_five_days = CustomerIssue.five_days_pending('masterclass_test')
    @masterclass_test_seven_days = CustomerIssue.seven_days_pending('masterclass_test')

    @full_test_two_days = CustomerIssue.two_days_pending('full_test')
    @full_test_five_days = CustomerIssue.five_days_pending('full_test')
    @full_test_seven_days = CustomerIssue.seven_days_pending('full_test')
  end
end
