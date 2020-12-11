class CoachesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def show
    if not current_admin_user
      redirect_to "/admin/login"
      return
    end
    # render html: helpers.tag.strong('You are not a coach') if current_admin_user.role != 'coach'
    if current_admin_user.students.count == 0
      render html: helpers.tag.strong('You are not coaching any student currently')
      return
    end
    @students = current_admin_user.students
    @student_count = @students.count
    @student_id = params[:studentId]
    if @student_id.nil?
      redirect_to "/coach-dashboard?studentId=" + @students.first.id.to_s
      return
    end
    @current_student = User.find(@student_id.to_i)

    @start = params[:start]
    @start = 10.year.ago.strftime("%F") if @start.blank?
    @end = params[:end]
    @end = Time.now.strftime("%F") if @end.blank?

    # video data
    @video_data_count = User.joins(user_video_stats: :video).where(id: @current_student.id).where(UserVideoStat: {completed: true, createdAt: @start..@end}).order('"UserVideoStat"."updatedAt" DESC').count
    @video_data = User.joins(user_video_stats: :video).where(id: @current_student.id).where(UserVideoStat: {completed: true, createdAt: @start..@end}).order('"UserVideoStat"."updatedAt" DESC')
    .select('
      "Video"."name" as video_name,
      "UserVideoStat"."updatedAt" as on_day
    ')
    
    # test data
    @test_data_count = User.joins(test_attempts: :test).where(id: @current_student.id).where(TestAttempt: {completed: true, createdAt: @start..@end}).order('"TestAttempt"."updatedAt" DESC').count
    @test_data = User.joins(test_attempts: :test).where(id: @current_student.id).where(TestAttempt: {completed: true, createdAt: @start..@end}).order('"TestAttempt"."updatedAt" DESC')
    .select('
      "Test"."name" as test_name,
      "TestAttempt"."updatedAt" as on_day,
      "TestAttempt"."elapsedDurationInSec" as time_spent,
      "TestAttempt"."result" as test_result
    ')

    # question data
    @question_data_count = User.joins(:answers).where(id: @current_student.id).where(Answer: {testAttemptId: nil, createdAt: @start..@end}).order('"Answer"."createdAt" DESC').count
    @question_data = User.joins(:answers).where(id: @current_student.id).where(Answer: {testAttemptId: nil, createdAt: @start..@end}).order('"Answer"."createdAt" DESC')
    .select('
      "Question"."correctOptionIndex" as correct_option,
      "Answer"."createdAt" as on_day,
      "Answer"."userAnswer" as user_answer
    ')
  end
end