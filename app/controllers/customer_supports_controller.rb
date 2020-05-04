class CustomerSupportsController < ApplicationController
  def pending_stats
    if not current_admin_user
      redirect_to "/admin/login"
      return
    end

    @pendrive_two_days = CustomerSupport.two_days_pending('Pendrive_Not_Working')
    @pendrive_five_days = CustomerSupport.five_days_pending('Pendrive_Not_Working')
    @pendrive_seven_days = CustomerSupport.seven_days_pending('Pendrive_Not_Working')

    @course_two_days = CustomerSupport.two_days_pending('Course_Not_Working')
    @course_five_days = CustomerSupport.five_days_pending('Course_Not_Working')
    @course_seven_days = CustomerSupport.seven_days_pending('Course_Not_Working')

    @website_two_days = CustomerSupport.two_days_pending('Website_Not_Working')
    @website_five_days = CustomerSupport.five_days_pending('Website_Not_Working')
    @website_seven_days = CustomerSupport.seven_days_pending('Website_Not_Working')

    @test_two_days = CustomerSupport.two_days_pending('Test_Not_Working')
    @test_five_days = CustomerSupport.five_days_pending('Test_Not_Working')
    @test_seven_days = CustomerSupport.seven_days_pending('Test_Not_Working')

    @video_two_days = CustomerSupport.two_days_pending('Video_Not_Playing')
    @video_five_days = CustomerSupport.five_days_pending('Video_Not_Playing')
    @video_seven_days = CustomerSupport.seven_days_pending('Video_Not_Playing')

    @app_two_days = CustomerSupport.two_days_pending('App Not Working')
    @app_five_days = CustomerSupport.five_days_pending('App Not Working')
    @app_seven_days = CustomerSupport.seven_days_pending('App Not Working')

    @other_two_days = CustomerSupport.two_days_pending('Other')
    @other_five_days = CustomerSupport.five_days_pending('Other')
    @other_seven_days = CustomerSupport.seven_days_pending('Other')
  end
end
