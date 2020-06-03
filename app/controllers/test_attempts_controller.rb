class TestAttemptsController < ApplicationController
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token


  def aryan_raj_toppers
    if not current_admin_user
      redirect_to "/admin/login"
      return
    end

    @test_attempts = {}
    @test_attempts = TestAttempt.aryan_raj_test_series.score_gte(600).includes(:test, user: :user_profile).order("\"TestAttempt\".\"testId\" desc, \"result\"->>'totalMarks' desc").pluck("\"TestAttempt\".\"userId\", \"UserProfile\".\"displayName\" , \"Test\".\"name\", \"result\"->>'totalMarks'")

    @report_data = {}

    @test_attempts.each do |attempt|
      @report_data[attempt[0].to_s] = [attempt[1].to_s, attempt[2].to_s, attempt[3].to_s]
    end

  end
end
