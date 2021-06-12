ActiveAdmin.register SubTopic do
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
  remove_filter :questions, :subTopicQuestions, :topic, :subTopicVideos, :videos, :versions
  permit_params :name, :topicId

  filter :topic_id_eq, as: :select, collection: -> { Topic.main_course_topic_name_with_subject}, label: "Chapter"
  preserve_default_filters!

  scope :botany, show_count: false
  scope :chemistry, show_count: false
  scope :physics, show_count: false
  scope :zoology, show_count: false
  scope :all, show_count: false

  member_action :duplicate_questions do
    @subTopic = SubTopic.find(resource.id)
    cutoff = params[:cutoff].to_f > 0 ? params[:cutoff] : "0.7"
    @question_pairs = ActiveRecord::Base.connection.query('Select "Question"."id", "Question"."question", "Question1"."id", "Question1"."question", "Question"."correctOptionIndex", "Question1"."correctOptionIndex", "Question"."options", "Question1".options, "Question"."explanation", "Question1"."explanation" from "QuestionSubTopic" INNER JOIN "Question" ON "Question"."id" = "QuestionSubTopic"."questionId" and "Question"."deleted" = false and "Question"."type" = \'MCQ-SO\' and "QuestionSubTopic"."subTopicId" = ' + resource.id.to_s + ' INNER JOIN "QuestionSubTopic" AS "QuestionSubTopic1" ON "QuestionSubTopic1"."subTopicId" = "QuestionSubTopic"."subTopicId" and "QuestionSubTopic"."questionId" < "QuestionSubTopic1"."questionId" INNER JOIN "Question" AS "Question1" ON "Question1"."id" = "QuestionSubTopic1"."questionId" and "Question1"."deleted" = false and "Question1"."type" = \'MCQ-SO\' and not exists (select * from "NotDuplicateQuestion" where "questionId1" = "Question"."id" and "questionId2" = "Question1"."id") and not exists (select * from "DuplicateQuestion" where "questionId1" = "Question"."id" and "questionId2" = "Question1"."id") and similarity("Question1"."question", "Question"."question") > ' + cutoff + ' and "QuestionSubTopic1"."subTopicId" = ' + resource.id.to_s);
  end

  member_action :mark_not_duplicate, method: :post do
    begin
      NotDuplicateQuestion.create!(
        questionId1: params[:question_id1].to_i,
        questionId2: params[:question_id2].to_i
      )
    rescue ActiveRecord::RecordNotUnique => e
      if(e.message =~ /unique.*constraint.*NotDuplicateQuestion_questionId1_questionId2_key/)
      else
        raise e.message
      end
    end
    respond_to do |format|
      format.html {redirect_back fallback_location: duplicate_questions_admin_sub_topic_path(resource), notice: "Marked questions as not duplicate!"}
      format.js
    end
  end

  # remove one of the duplicate question
  member_action :mark_duplicate, method: :post do
    dq = nil
    begin
      dq = DuplicateQuestion.create!(
        questionId1: params[:question_id1].to_i,
        questionId2: params[:question_id2].to_i
      )
    rescue ActiveRecord::RecordNotUnique => e
      if(e.message =~ /unique.*constraint.*DuplicateQuestion_questionId1_questionId2_key/)
      else
        raise e.message
      end
    end
    if dq.present? and dq.question_bank_chapter_id.present?
      if params[:retain_question_id] == params[:question_id2]
        dq.remove_q1_from_question_bank
      elsif params[:retain_question_id] == params[:question_id1]
        dq.remove_duplicate_from_question_bank
      end
    end
    respond_to do |format|
      format.html {redirect_back fallback_location: duplicate_questions_admin_sub_topic_path(resource), notice: "Duplicate question marked from topic questions!"}
      format.js
    end
  end


  index do
    id_column
    column :topic
    columns_to_exclude = ["id", "createdAt", "updatedAt", "deleted", "position", "topicId"]
    (SubTopic.column_names - columns_to_exclude).each do |c|
      column c.to_sym
    end
    if (current_admin_user.role == 'admin' or current_admin_user.question_bank_owner?) and (params["scope"].present? or (params[:q].present? and (params[:q][:topic_id_eq].present? or params[:q][:topic_id_in].present?)))
      column ("Questions Count"), sortable: true do |subTopic|
        link_to subTopic.questions_count, admin_questions_path(q: {subTopics_id_eq: subTopic.id})
      end
      column ("Duplicate Questions") { |subtopic|
        link_to "Duplicate Questions", duplicate_questions_admin_sub_topic_path(id: subtopic.id)
      }
    end
    actions
  end

  csv do
    column :id
    column :name
    column ("Topic") {|sub_topic| sub_topic.topic.name }
    if (current_admin_user.role == 'admin' or current_admin_user.question_bank_owner?) and (params["scope"].present? or (params[:q].present? and (params[:q][:topic_id_eq].present? or params[:q][:topic_id_in].present?)))
      column :questions_count
    end
  end

  form do |f|
    f.inputs "Sub Topic" do
      f.input :name
      f.input :topic, input_html: { class: "select2" }, :collection => Topic.neetprep_course.pluck(:name, :'Subject.name', :id).map{|topic_name, subject_name, topic_id| [topic_name + " - " + subject_name, topic_id]}
    end
    f.actions
  end

  controller do
    def scoped_collection
      if params[:scope].present? or (params[:q].present? and (params[:q][:topic_id_eq].present? or params[:q][:topic_id_in].present?))
        super.left_outer_joins(:questions).select('"SubTopic".*, count(distinct("Question"."id")) as questions_count').group('"SubTopic"."id"')
      else
        super
      end
    end
  end

end
