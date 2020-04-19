ActiveAdmin.register Topic do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # permit_params :list, :of, :attributes, :on, :model
  #
  # or
  #
  # permit_params do
  #   permitted = [:permitted, :attributes]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  remove_filter :questions, :topicQuestions, :subject, :videos, :topicVideos, :doubts, :issues, :scheduleItems, :subTopics, :versions, :topicSubjects, :topicChapterTests, :tests, :sections, :topicNotes, :notes
  permit_params :free, :name, :image, :description, :position, :createdAt, :updatedAt, :seqid, :importUrl, :published, :isComingSoon, :subjectId, :subject_id, :sectionReady
  preserve_default_filters!
  filter :subjects, as: :searchable_select, multiple: true, collection: -> {Subject.neetprep_course_subjects}, label: "Subject"
  scope :neetprep_course
  scope :botany
  scope :chemistry
  scope :physics
  scope :zoology
  sidebar :related_data, only: :show do
    ul do
      li link_to "Questions", admin_questions_path(q: { questionTopics_chapterId_eq: topic.id}, order: 'id_asc')
      li link_to "Videos", admin_videos_path(q: { videoTopics_chapterId_eq: topic.id}, order: 'id_asc')
      li link_to "Duplicate Questions", duplicate_questions_admin_topic_path(topic)
      li link_to "Question Issues", question_issues_admin_topic_path(topic)
      li link_to "Question Bookmarks", admin_questions_path(q: { questionTopics_chapterId_eq: topic.id}, order: 'bookmarks_count_desc')
      li link_to "Question Doubts", admin_questions_path(q: { questionTopics_chapterId_eq: topic.id}, order: 'doubts_count_desc')
    end
  end

  index do
    id_column
    column :name
    column :description do |topic|
      truncate topic.description
    end
    column :seqId
    column ("Videos") { |topic|
      link_to "Videos", admin_videos_path(q: { videoTopics_chapterId_eq: topic.id}, order: 'id_asc')
    }
    column ("Questions") { |topic|
      link_to "Questions", admin_questions_path(q: { questionTopics_chapterId_eq: topic.id}, order: 'id_asc')
    }
    toggle_bool_column :sectionReady
    actions
  end

  member_action :duplicate_questions do
    @topic = Topic.find(resource.id)
    @question_pairs = ActiveRecord::Base.connection.query('Select "Question"."id", "Question"."question", "Question1"."id", "Question1"."question", "Question"."correctOptionIndex", "Question1"."correctOptionIndex", "Question"."options", "Question1".options, "Question"."explanation", "Question1"."explanation" from "ChapterQuestion" INNER JOIN "Question" ON "Question"."id" = "ChapterQuestion"."questionId" and "Question"."deleted" = false INNER JOIN "Topic" ON "Topic"."id" = "ChapterQuestion"."chapterId" INNER JOIN "SubjectChapter" ON "SubjectChapter"."chapterId" = "Topic"."id" INNER JOIN "Subject" ON "Subject"."id" = "SubjectChapter"."subjectId" and "Subject"."courseId" = 8 INNER JOIN "ChapterQuestion" AS "ChapterQuestion1" ON "ChapterQuestion1"."chapterId" = "ChapterQuestion"."chapterId" and "ChapterQuestion"."questionId" < "ChapterQuestion1"."questionId" INNER JOIN "Question" AS "Question1" ON "Question1"."id" = "ChapterQuestion1"."questionId" and "Question1"."deleted" = false and similarity("Question1"."question", "Question"."question") > 0.7 and "ChapterQuestion1"."chapterId" = ' + resource.id.to_s);
  end

  member_action :question_issues do
    @topic = Topic.find(resource.id)
    @question_ids = ActiveRecord::Base.connection.query('Select "Question"."id", count(*) as "issue_count" from "Question" INNER JOIN "CustomerIssue" on "CustomerIssue"."questionId" = "Question"."id" and "CustomerIssue"."resolved" = false INNER JOIN "ChapterQuestion" ON "Question"."id" = "ChapterQuestion"."questionId" and "ChapterQuestion"."chapterId" = ' + resource.id.to_s + ' and "Question"."deleted" = false INNER JOIN "Topic" ON "Topic"."id" = "ChapterQuestion"."chapterId" INNER JOIN "SubjectChapter" ON "SubjectChapter"."chapterId" = "Topic"."id" INNER JOIN "Subject" ON "Subject"."id" = "SubjectChapter"."subjectId" and "Subject"."courseId" = 8 group by "Question"."id" order by count(*) DESC');
    @questions = Question.where(id: @question_ids.map{ |id, count| id}).index_by(&:id)
  end

  # remove one of the duplicate question
  member_action :remove_duplicate, method: :post do
    ActiveRecord::Base.connection.query('delete from "ChapterQuestion" where "questionId" = ' + params[:delete_question_id] + 'and "chapterId" in (select "chapterId" from "ChapterQuestion" where "questionId" in  (' + params[:delete_question_id] + ', ' + params[:retain_question_id] + ') group by "chapterId" having count(*) > 1);')
    redirect_to duplicate_questions_admin_topic_path(resource), notice: "Duplicate question removed from chapter questions!"
  end

  controller do
    def scoped_collection
      super.includes(:subject)
    end
  end
end
