class TestAttemptsController < ApplicationController
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token


  def aryan_raj_toppers
    if not current_admin_user
      redirect_to "/admin/login"
      return
    end

    @test_attempts = {}
    @tests = TestAttempt.aryan_raj_test_series.order('"Test"."id" ASC').pluck('distinct "Test"."id", "Test"."name"');
    @test_attempts = TestAttempt.aryan_raj_test_series.score_gte(600).includes(:test, user: :user_profile).order("\"TestAttempt\".\"testId\" desc, \"result\"->>'totalMarks' desc").pluck("\"TestAttempt\".\"userId\", \"UserProfile\".\"displayName\", \"Test\".\"id\", \"result\"->>'totalMarks', COALESCE(\"UserProfile\".\"phone\", \"UserProfile\".\"phone\")")

    @report_data = {}

    @test_attempts.each do |attempt|
      if @report_data[attempt[0].to_s].nil?
        @report_data[attempt[0].to_s] = {}
        @report_data[attempt[0].to_s]["name"] = attempt[1].to_s
        @report_data[attempt[0].to_s]["phone"] = attempt[4].to_s
        @report_data[attempt[0].to_s][attempt[2].to_s] = attempt[3].to_s
      else
        @report_data[attempt[0].to_s][attempt[2].to_s] = attempt[3].to_s
      end
    end

  end
end
