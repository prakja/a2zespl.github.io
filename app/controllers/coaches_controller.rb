class CoachesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def show
    authenticate_admin_user!
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
    @video_data_count = CoachVideoDashboard.where(user_id: @current_student.id, completed: true, createdAt: @start..@end).order(updatedAt: :DESC).count
    @video_data = CoachVideoDashboard.where(user_id: @current_student.id, completed: true, createdAt: @start..@end).order(updatedAt: :DESC)
    
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
    @question_data_count = CoachQuestionDashboard.where(user_id: @current_student.id, createdAt: @start..@end).order(createdAt: :DESC).count
    @question_data = CoachQuestionDashboard.where(user_id: @current_student.id, createdAt: @start..@end).order(createdAt: :DESC)
  end

  def summary
    authenticate_admin_user!

    if current_admin_user.students.count == 0
      render html: helpers.tag.strong('You are not coaching any student currently')
      return
    end
    @students = current_admin_user.students
    @student_count = @students.count
    @student_id = params[:studentId]
    if @student_id.nil?
      redirect_to "/coach-dashboard-summary?studentId=" + @students.first.id.to_s
      return
    end
    @current_student = User.find(@student_id.to_i)

    @start = params[:start]
    @start = 10.year.ago.strftime("%F") if @start.blank?
    @end = params[:end]
    @end = Time.now.strftime("%F") if @end.blank?

    @topics = Topic.neetprep_course_id_filter(Rails.configuration.hinglish_full_course_id).order(seqId: :asc)

    physics_topics = Topic.neetprep_course_id_filter(Rails.configuration.hinglish_full_course_id).where(Subject: {id: 55}).order(seqId: :asc)
    chemistry_topics = Topic.neetprep_course_id_filter(Rails.configuration.hinglish_full_course_id).where(Subject: {id: 54}).order(seqId: :asc)
    zoology_topics = Topic.neetprep_course_id_filter(Rails.configuration.hinglish_full_course_id).where(Subject: {id: 56}).order(seqId: :asc)
    botany_topics = Topic.neetprep_course_id_filter(Rails.configuration.hinglish_full_course_id).where(Subject: {id: 53}).order(seqId: :asc)

    @summary_data = {
      :Physics => {
        :data => []
      },
      :Chemistry => {
        :data => []
      },
      :Zoology => {
        :data => []
      },
      :Botany => {
        :data => []
      }
    }
    
    p @summary_data

    chemistry_topics.each do |topic|
      video_data_count = CoachVideoDashboard.where(user_id: @current_student.id, completed: true, createdAt: @start..@end, topic_id: topic.id).order(updatedAt: :DESC).count
      question_data_count = CoachQuestionDashboard.where(user_id: @current_student.id, createdAt: @start..@end, topic_id: topic.id).order(createdAt: :DESC).count
      @summary_data[:Chemistry][:data] << {
        name: topic[:name],
        video: video_data_count.to_s,
        question: question_data_count.to_s
      }
    end

    zoology_topics.each do |topic|
      video_data_count = CoachVideoDashboard.where(user_id: @current_student.id, completed: true, createdAt: @start..@end, topic_id: topic.id).order(updatedAt: :DESC).count
      question_data_count = CoachQuestionDashboard.where(user_id: @current_student.id, createdAt: @start..@end, topic_id: topic.id).order(createdAt: :DESC).count
      @summary_data[:Zoology][:data] << {
        name: topic.name,
        video: video_data_count,
        question: question_data_count
      }
    end

    botany_topics.each do |topic|
      video_data_count = CoachVideoDashboard.where(user_id: @current_student.id, completed: true, createdAt: @start..@end, topic_id: topic.id).order(updatedAt: :DESC).count
      question_data_count = CoachQuestionDashboard.where(user_id: @current_student.id, createdAt: @start..@end, topic_id: topic.id).order(createdAt: :DESC).count
      @summary_data[:Botany][:data] << {
        name: topic.name,
        video: video_data_count,
        question: question_data_count
      }
    end

    physics_topics.each do |topic|
      video_data_count = CoachVideoDashboard.where(user_id: @current_student.id, completed: true, createdAt: @start..@end, topic_id: topic.id).order(updatedAt: :DESC).count
      question_data_count = CoachQuestionDashboard.where(user_id: @current_student.id, createdAt: @start..@end, topic_id: topic.id).order(createdAt: :DESC).count
      @summary_data[:Physics][:data] << {
        name: topic.name,
        video: video_data_count,
        question: question_data_count
      }
    end

  end
end