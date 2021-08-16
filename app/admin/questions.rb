ActiveAdmin.register Question do
  duplicatable
  # config.sort_order = 'sequenceId_asc_and_id_asc'
  # See permitted parameters documentation: # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
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
  remove_filter :details, :questionTopics, :subTopics, :questionSubTopics, :question_analytic, :issues, :versions, :doubts, :questionTests, :tests, :bookmarks, :explanations, :hints, :answers, :translations, :notes, :systemTests, :subject, :lock_version, :ncert_sentences, :ncertSentences_count,:video_sentences, :subTopics_count, :topics_count, :course_tests_count, :videoSentences_count, :completed_reviewed_translations, :question_ncert_sentences, :question_video_sentences, :questionSets
  permit_params :question, :orignalQuestionId, :correctOptionIndex, :explanation, :type, :level, :deleted, :testId, :topic, :topicId, :proofRead, :ncert, :lock_version, :paidAccess, questionSet_ids: [], topic_ids: [], subTopic_ids: [], systemTest_ids: [], ncert_sentence_ids: [], video_sentence_ids: [], details_attributes: [:id, :exam, :year, :_destroy]

  before_action :create_token, only: [:show]

  # before_filter only: :index do
  #   if params['commit'].blank? && params['q'].blank? && params[:scope].blank?
  #     params['q'] = {:explanation_cont => '<video'}
  #   end
  # end

  # make a drop down menu
  filter :topic, as: :searchable_select, multiple: true, label: "Question Chapter", :collection => Topic.name_with_subject_hinglish
  filter :topics, as: :searchable_select, multiple: true, label: "Question Bank Chapter", :collection => Topic.name_with_subject_hinglish
  filter :subTopics_id_eq, as: :searchable_select, collection: -> { SubTopic.distinct_name }, label: "Sub Topic"
  filter :details_year, as: :select, collection: -> { QuestionDetail.distinct_year }, label: "Exam Year"
  filter :details_exam, as: :select, collection: -> { QuestionDetail.distinct_exam_name }, label: "Exam Name"
  filter :question_analytic_correctPercentage, as: :numeric, label: "Difficulty Level (0-100)"
  # filter :question_analytic_correctPercentage_lt_eq, as: :numeric, label: "Difficulty Level Lower limit (0-100)"
  filter :id_eq, as: :number, label: "Question ID"
  filter :course_subject_id, as: :select, collection: -> {Subject.full_course_subject_names}, label: "Subject"
  filter :similar_questions, as: :number, label: "Similar to ID"
  filter :type, filters: ['eq'], as: :select, collection: -> { Question.distinct_type.map{|q_type| q_type["type"]} }, label: "Question Type"
  filter :level, filters: ['eq'], as: :select, collection: -> { Question.distinct_level.map{|q_type| q_type["level"]} }, label: "Question Level"
  filter :explanation_cont_all, as: :select, collection: -> {[["Video", "<video"], ["Audio", "<audio"], ["Image", "<img"], ["Text", "<p>"]]}, label: "Explanation Has", multiple: true
  filter :explanation_not_cont_all, as: :select, collection: -> {[["Video", "<video"], ["Audio", "<audio"], ["Image", "<img"], ["Text", "<p>"]]}, label: "Explanation Does Not Have", multiple: true
  # brings back the default filters
  preserve_default_filters!
  scope :neetprep_course, show_count: false
  scope :image_question, show_count: false
  scope :test_image_question, show_count: false
  #scope :unused_in_high_yield_bio, show_count: false
  scope :unused_questions, show_count: false
  scope :NEET_Test_Questions, show_count: false
  scope :not_neetprep_course, show_count: false
  scope :bio_masterclass_course, show_count: false
  scope :easyLevel, show_count: false
  scope :mediumLevel, show_count: false
  scope :difficultLevel, show_count: false
  scope :has_ncert_sentences, show_count: false
  scope :no_ncert_sentences, show_count: false
  scope :has_video_sentences, if: -> {current_admin_user.admin?}, show_count: false
  scope :no_video_sentences, if: -> {current_admin_user.admin?}, show_count: false
  scope :abcd_options, if: -> {current_admin_user.admin?}, show_count: false
  scope :not_in_qb, if: -> {current_admin_user.admin?}, show_count: false

  batch_action :set_image_link, if: proc{ current_admin_user.admin? } do |ids|
    batch_action_collection.find(ids).each do |question|
      question.set_image_link!
    end
    redirect_back fallback_location: collection_path, notice: "The question images have been updated."
  end

  collection_action :download_chapterwise_question_csv, :method => :get do
    question_topicId = params[:q]["topicId"]

    questions = Question.get_chapterwise_question_csv(question_topicId)

    csv = CSV.generate do |csv|
      csv << questions.first.keys

      # add data
      questions.each do |question|
        csv << question.values
      end
    end

    send_data csv.encode, type: 'text/csv; header=present', disposition: "attachment; filename=#{question_topicId}_chapter_wise_question.csv"
  end

  action_item only: :index do
    q = params[:q]

    unless q.nil?
      selected_topic_id = q["topic_id_in"] || []
      selected_topic_id = selected_topic_id.first

      unless selected_topic_id.nil?
        topic_name = Topic.find(selected_topic_id).name
        link_to "#{topic_name} - Question CSV Download",
          download_chapterwise_question_csv_admin_questions_path(q: {:topicId => selected_topic_id})
      end
    end
  end 

  batch_action :change_option_index, if: proc{ current_admin_user.admin? } do |ids|
    batch_action_collection.find(ids).each do |question|
      question.change_option_index!
    end
    redirect_back fallback_location: collection_path, notice: "The option index has been changed from abcd to 1234 ."
  end

  batch_action :add_to_qb, if: proc{ current_admin_user.admin? } do |ids|
    batch_action_collection.find(ids).each do |question|
      question.insert_chapter_question
    end
    redirect_back fallback_location: collection_path, notice: "Questions added in the main question bank."
  end

  member_action :update_chapter_questions, method: :post do
    resource.update_chapter_questions!
    redirect_to admin_question_path, notice: "Question chapter banks fixed!"
  end

  controller do
    def scoped_collection
      if params["q"] and (params["q"]["questionTopics_chapterId_in"].present? or params["q"]["questionTopics_chapterId_eq"].present?)
        super.select('"Question".*, (select count(*) from "Doubt" where "Doubt"."questionId" = "Question"."id") as doubts_count, (select count(*) from "BookmarkQuestion" where "BookmarkQuestion"."questionId" = "Question"."id") as bookmarks_count, (select count(*) from "CustomerIssue" where "CustomerIssue"."questionId" = "Question"."id" and "resolved" = false) as issues_count').group('"Question"."id"')
      elsif params["q"] and params["q"]["similar_questions"].present?
        super
      else
        super.left_outer_joins(:topic)
      end
    end

    def apply_filtering(chain)
      if params["q"] and (params["q"]["questionTopics_chapterId_in"].present? or params["q"]["questionTopics_chapterId_eq"].present?)
        super(chain)
      else
        super(chain).select('DISTINCT ON ("Question"."id") "Question".*')
      end
    end

    def create_token
      payload = {
        "type": "Question",
        "id": params[:id]
      }
      @token_lambda = JsonWebToken.encode_for_lambda(payload)
      @url = Rails.application.config.create_image_url
    end

    def create_translation
      if not current_admin_user
        redirect_to "/admin/login"
        return
      end
      question_id = params[:id]
      question = Question.find(question_id)
      QuestionTranslation.create!({
        questionId: question_id,
        question: question.question,
        explanation: question.explanation,
        language: 'hindi'
      })
    end
  end

  member_action :history do
    @question = Question.find(params[:id])
    @versions = PaperTrail::Version.where(item_type: 'Question', item_id: @question.id)
    render "layouts/history"
  end

  # https://www.neetprep.com/api/v1/questions/id/edit
  index do
    render partial: 'mathjax'
    # if current_admin_user.role == 'admin' or current_admin_user.role == 'support'
    #   @index = 15 * (((params[:page] || 1).to_i) - 1)
    #       column :number do
    #           @index +=1
    #       end
    # end

    if current_admin_user.admin?
      selectable_column
    end
    id_column
    if params["q"] && (params["q"]["questionTopics_chapterId_in"].present? or params["q"]["questionTopics_chapterId_eq"].present?)
      column (:question) { |question| raw(question.question.to_s + (question.level.to_s == 'MASTER-NCERT' ? '<br><br><b>Level: </b> Mastering NCERT' : ''))}
    else
      column (:question) { |question| raw(question.question) }
    end
    column (:correctOption) { |question| question.options[question.correctOptionIndex] if not question.correctOptionIndex.blank? and not question.options.blank?}
    column (:explanation) { |question| raw(question.explanation)  }
    column ("Question Chapter") {|question| question&.topic&.name}
    # column ("Link") {|question| raw('<a target="_blank" href="https://www.neetprep.com/api/v1/questions/' + (question.id).to_s + '/edit">Edit on NEETprep</a>')}
    # column "Difficulty Level", :question_analytic, sortable: 'question_analytic.difficultyLevel'

    if current_admin_user.question_bank_owner?  and params[:showProofRead] == 'yes'
      toggle_bool_column :proofRead
    end

    if current_admin_user.question_bank_owner? and params[:showNCERT] == 'yes'
      toggle_bool_column :ncert
    end

    if current_admin_user.question_bank_owner? and params[:showNCERT] == 'yes'
      column ('NCERT Sentence') {|question| raw(question.ncert_sentences.collect(&:fullSentenceUrl).join("<br />"))}
    end

    if current_admin_user.question_bank_owner?
      if params["q"] && (params["q"]["questionTopics_chapterId_in"].present? or params["q"]["questionTopics_chapterId_eq"].present?)
        column :doubts_count, sortable: true do |question|
          link_to question.doubts_count, admin_doubts_path(q: {questionId_eq: question.id}, scope: 'all')
        end
        column :bookmarks_count, sortable: true
        column :issues_count, sortable: true do |question|
          link_to question.issues_count, admin_customer_issues_path(q: {questionId_eq: question.id})
        end
      end
    end

    if current_admin_user.question_bank_owner? and params[:showNCERT] != 'yes'
      
      column ("Add explanation") { |question|
        raw('<a target="_blank" href="/questions/add_explanation/' + question.id.to_s + '">' + "Add Explanation" + '</a>')
      }
      column ("Add Hint") { |question|
        raw('<a target="_blank" href="/questions/add_hint/' + question.id.to_s + '">' + "Add Hint" + '</a>')
      }
      column ("History") {|question| raw('<a target="_blank" href="/admin/questions/' + (question.id).to_s + '/history">View History</a>')}
      if current_admin_user.role == 'admin'
        column ("Restore") { |question| raw('<a href="/admin/questions/' + (question.id).to_s + '/restore">Restore</a>')}
      end
    end
    actions defaults: true do |question|
      if params[:q].present? and params[:q][:similar_questions].present?
        main_question_id = params[:q][:similar_questions].to_i
        if params[:q][:similar_questions].to_i != question.id
          item 'Copy Explanation', copy_explanation_admin_question_path(question, origId: main_question_id), class: 'member_link', method: :post, data: {confirm: "Please confirm that explanation should be copied from Question ID: #{params[:q][:similar_questions]}"}
          item 'Merge Explanation', merge_explanation_admin_question_path(question, origId: main_question_id), class: 'member_link', method: :post, data: {confirm: "Please confirm that explanation should be merged from Question ID: #{params[:q][:similar_questions]}"}
          item 'Copy Video Solution', copy_video_solution_admin_question_path(question, origId: main_question_id), class: 'member_link', method: :post, data: {confirm: "Please confirm that video solution should be copied from Question ID: #{main_question_id}"} 
          item 'Copy NCERT', copy_ncert_admin_question_path(question, origId: main_question_id), class: 'member_link', method: :post, data: {confirm: "Please confirm that ncert and sentences should be copied from Question ID: #{params[:q][:similar_questions]}"}
          if not DuplicateQuestion.existing_duplicate?(question.id, main_question_id)
            item 'Mark Duplicate', add_dup_admin_question_path(question, origId: main_question_id), class: 'member_link', method: :post, data: {confirm: "Please Question ID: #{main_question_id} as duplicate of #{question.id}"}
            item 'Mark Not Duplicate', add_not_dup_admin_question_path(question, origId: main_question_id), class: 'member_link', method: :post, data: {confirm: "Please Question ID: #{main_question_id} is not duplicate of #{question.id}"}
          else
            item 'Remove Duplicate marking', del_dup_admin_question_path(question, origId: main_question_id), class: 'member_link', method: :post, data: {confirm: "Please remove duplicate marking of: #{main_question_id} and #{question.id}"}
          end
          item 'Set Main Question', admin_questions_path(q: {similar_questions: question.id}) 
        else
          "This is the main Question"
        end
      else
      end
    end
  end

  show do
    render partial: 'mathjax'
    render partial: 'questions_show'
    attributes_table do
      row :id
      row :question do |question|
        raw(question.question)
      end
      row :explanation do |question|
        raw(question.explanation)
      end
      if question.explanations and question.explanations.length > 0
        row :explanations do |question|
          raw(question.explanations.pluck(:explanation).join(""))
        end
      end
      if question.translations and question.translations.length > 0
        row :translations do |question|
          raw('<a href="/admin/question_translations?q[questionId_eq]=' + question.id.to_s + '">View in Hindi</a>')
        end
      end
      row :options do |question|
        raw(question.options)
      end
      # row :correctOptionIndex
      row :correctOption do |question|
        question.options[question.correctOptionIndex] if not question.correctOptionIndex.blank?
      end
      row "Question Bank Chapters" do |question|
        question.topics
      end
      row "Chapter" do |question|
        question.topic
      end
      row :subTopics do |question|
        question.subTopics
      end
      row :tests do |question|
        question.systemTests
      end
      row :type
      row :ncert
      row :orignalQuestionId do |question|
        question.orignalQuestionId.nil? ? nil : raw('<a target="_blank" href="/admin/questions/' + question.orignalQuestionId.to_s + '">' + "Original Question" + '</a>')
      end
      if question.ncert_sentences.length > 0
        row "NCERT Sentences" do |question|
          raw question.ncert_sentences.collect{|sentence| "<a href='#{admin_ncert_sentence_path(sentence)}' target='_blank'>#{sentence.sentence}</a>"}.join("<br>")
        end
      end
      if question.video_sentences.length > 0
        row "Video Sentences" do |question|
          raw question.video_sentences.collect{|sentence| "<a href='#{admin_video_sentence_path(sentence)}' target='_blank'>#{sentence.sentence}</a>"}.join("<br>")
        end
      end
    end
    active_admin_comments
  end

  csv do
    column (:id)
    column (:topicId)
    column (:chapter) {|question| question&.topic&.name}
    column (:subject) {|question| question&.subject&.name}
    column (:chapter_ids) {|question|
      DuplicateChapter.where(dupId: question&.topics&.first&.id)&.first&.origId
    }
    column (:chapter) {|question| question&.topics&.first&.id}
    column (:subtopic_id) {|question| question&.subTopics&.first&.id}
    column (:subtopic) {|question| question&.subTopics&.first&.name}
    column (:subject) {|question| question&.topics&.first&.subject&.name}
    column (:question) {|question| question.question && question.question.squish}
    column (:explanation) {|question| question.explanation && question.explanation.squish}
    column :options
    column :ncert
    column :correctOptionIndex
  end

  # Label works with filters but not with scope xD
  scope :NEET_AIPMT_PMT_Questions, label: "NEET AIPMT PMT Questions", show_count: false
  scope :AIIMS_Questions, show_count: false
  scope :empty_explanation, show_count: false
  scope :short_explanation, show_count: false
  scope :missing_subTopics, show_count: false
  scope :missing_audio_explanation, show_count: false
  scope :missing_ncert_reference, show_count: false
  scope :test_questions, show_count: false
  # not working well so commenting out, checked with chapter filter
  #scope :include_deleted, label: "Include Deleted"

  action_item :add_explanation, only: :show do
    link_to 'Add Explanation', '/questions/add_explanation/' + resource.id.to_s
  end

  action_item :add_hint, only: :show do
    link_to 'Add Hint', '/questions/add_hint/' + resource.id.to_s
  end

  action_item :similar_question, only: :show do
    if resource.topicId.present?
      link_to 'Find Similar Questions', '/admin/questions?q[similar_questions]=' + resource.id.to_s
    else
      link_to 'Update Topic for Similar Quesitons', '/admin/questions/' + resource.id.to_s + '/edit'
    end
  end

  action_item :question_issues, only: :show do
    link_to 'Customer Issues', '/admin/customer_issues?scope=all&q[questionId_eq]=' + resource.id.to_s
  end

  action_item :question_doubts, only: :show do
    link_to 'Question Doubts', '/admin/doubts?scope=all&q[questionId_eq]=' + resource.id.to_s
  end

  action_item :question_doubt_answers, only: :show do
    link_to 'Question Doubt Answers', '/admin/doubt_answers?scope=all&q[doubt_questionId_eq]=' + resource.id.to_s
  end

  action_item :set_image_link, only: :show do
    link_to 'Set Image Link', '#', class: 'setImageLink'
  end

  member_action :change_option_index, method: :post do
    resource.change_option_index!
    redirect_to admin_question_path, notice: "Question options fixed!"
  end

  member_action :copy_explanation, method: :post do
    resource.update_column('explanation', Question.find(params[:origId]).explanation) 
    redirect_back fallback_location: collection_path, notice: "copied explanation from main question"
  end

  member_action :merge_explanation, method: :post do
    resource.update_column('explanation', resource.explanation + '<br>' + Question.find(params[:origId]).explanation) 
    redirect_back fallback_location: collection_path, notice: "merged explanation from main question"
  end

  member_action :merge_doubt_answer, method: :post do 
    doubt_answer = DoubtAnswer.find(params[:doubtAnswerId])
    if resource.explanation.include? "doubt-answer-#{doubt_answer.id}"
      redirect_back fallback_location: collection_path, flash: {error: "doubt answer already merged"}
    else
      resource.update_column('explanation', resource.explanation + '<br />' + "<p class='doubt-answer-copy' id='doubt-answer-#{doubt_answer.id}'>#{doubt_answer.content}</p>")
      redirect_back fallback_location: collection_path, notice: "doubt answer merged with question explanation"
    end
  end

  member_action :copy_video_solution, method: :post do
    q = Question.find(params[:origId])
    if md = q.has_video_solution
      resource.update_column('explanation', resource.explanation + '<br>' + '<div class="embed-responsive embed-responsive-16by9">' + md[0] + '</div>') 
      redirect_back fallback_location: collection_path, notice: "copied video solution from main question"
    else
      redirect_back fallback_location: collection_path, error: "no video solution in source question!"
    end
  end

  member_action :copy_ncert, method: :post do
    resource.update_column('ncert', Question.find(params[:origId]).ncert) 
    if resource.ncert 
      ncert_sentences = Question.find(params[:origId]).ncert_sentences  
      if ncert_sentences.length > 0
        resource.ncert_sentences = ncert_sentences
        resource.save!
      end
    end
    redirect_back fallback_location: collection_path, notice: "copied ncert and related sentences, if any, from main question"
  end

  member_action :add_dup, method: :post do
    if resource.id < params[:origId].to_i
      DuplicateQuestion.create!(questionId1: resource.id, questionId2: params[:origId].to_i)
    else
      DuplicateQuestion.create!(questionId2: resource.id, questionId1: params[:origId].to_i)
    end
    redirect_back fallback_location: collection_path, notice: "added duplicate with main question"
  end

  member_action :add_not_dup, method: :post do
    if resource.id < params[:origId].to_i
      NotDuplicateQuestion.create!(questionId1: resource.id, questionId2: params[:origId].to_i)
    else
      NotDuplicateQuestion.create!(questionId2: resource.id, questionId1: params[:origId].to_i)
    end
    redirect_back fallback_location: collection_path, notice: "added not duplicate with main question"
  end

  member_action :del_dup, method: :post do
    if resource.id < params[:origId].to_i
      dq = DuplicateQuestion.find_by(questionId1: resource.id, questionId2: params[:origId].to_i)
    else
      dq = DuplicateQuestion.find_by(questionId2: resource.id, questionId1: params[:origId].to_i)
    end
    dq.destroy
    redirect_back fallback_location: collection_path, notice: "deleted duplicate with main question"
  end

  member_action :history do
    @question = Question.find(params[:id])
    @versions = PaperTrail::Version.where(item_type: 'Question', item_id: @question.id)
    render "layouts/history"
  end

  member_action :restore do
    @question = Question.find(params[:id])
    @versions = PaperTrail::Version.where(item_type: 'Question', item_id: @question.id)
    if !@versions.last.reify.nil?
      @lock_version = @versions.last.reify.lock_version + 1
      @question = @versions.last.reify
      @question.lock_version = @lock_version
      @question.save!
      #@versions.last.destroy
      #@versions.last.destroy
      redirect_back fallback_location: collection_path, notice: "Restored to previos version"
    else
      redirect_back fallback_location: collection_path, notice: "There is no previous version"
    end 
  end

  action_item :change_option_index, only: :show do
    link_to 'Change Option Index', change_option_index_admin_question_path(resource), method: :post
  end

  action_item :update_chapter_questions, only: :show do
    link_to 'Update Question Bank Chapter', update_chapter_questions_admin_question_path(resource), method: :post
  end

  action_item :set_hindi_translation, only: :show do
    link_to('Set Hindi Translation', '#', class: 'addTranslation')
  end

  action_item :relevant_video_sentences, only: :show do
    link_to 'Relevant Video Sentences', "/admin/video_sentences?q[similar_to_question]=#{resource.id.to_s}"
  end

  #action_item :see_physics_difficult_questions, only: :index do
  #  link_to 'Physics Difficult Questions', '../../questions/pdf_questions?subject=physics'
  #end

  #action_item :see_chemistry_difficult_questions, only: :index do
  #  link_to 'Chemistry Difficult Questions', '../../questions/pdf_questions?subject=chemistry'
  #end

  #action_item :see_botany_difficult_questions, only: :index do
  #  link_to 'Botany Difficult Questions', '../../questions/pdf_questions?subject=botany'
  #end

  #action_item :see_zoology_difficult_questions, only: :index do
  #  link_to 'Zoology Difficult Questions', '../../questions/pdf_questions?subject=zoology'
  #end

  #action_item :see_physics_easy_questions, only: :index do
  #  link_to 'Physics easy Questions', '../../questions/easy_questions?subject=physics'
  #end

  #action_item :see_chemistry_easy_questions, only: :index do
  #  link_to 'Chemistry easy Questions', '../../questions/easy_questions?subject=chemistry'
  #end

  #action_item :see_botany_easy_questions, only: :index do
  #  link_to 'Botany easy Questions', '../../questions/easy_questions?subject=botany'
  #end

  #action_item :see_zoology_easy_questions, only: :index do
  #  link_to 'Zoology easy Questions', '../../questions/easy_questions?subject=zoology'
  #end

  action_item :see_ncert_marking, only: :index do
    link_to 'From NCERT Marking', request.params.merge(showNCERT: 'yes')
  end

  action_item :see_ncert_marking, only: :index do
    link_to 'Question Set Marking', request.params.merge(showQuestionSet: 'yes', controller: 'admin/qs')
  end

  action_item :delete_from_question_banks, only: :show, if: proc{ current_admin_user.question_bank_owner? } do
    link_to 'Delete From Question Banks', '/questions/delete_from_question_banks/' + resource.id.to_s, method: :post, data: {confirm: 'Are you sure? This Question will be deleted from all question banks. It will still be available in tests though.'}
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "Question" do
      render partial: 'tinymce'
      f.input :question
      f.input :correctOptionIndex, as: :select, :collection => [["(1)", 0], ["(2)", 1], ["(3)", 2], ["(4)", 3]], label: "Correct Option"
      f.input :explanation
      # Hiding system tests from question edit as we saw test questions getting deleted from tests before test goes live due to simulaneous edits
      # If we want to add this back then may be thinking of a way to change version id along with test question edition should be evaluated
      # On second thought, we can let this be on for new questions for now
      if f.object.new_record?
        f.input :systemTests, include_hidden: false, input_html: { class: "select2" }, :collection => Test.where(userId: nil).order(createdAt: :desc).limit(100)
        render partial: 'hidden_test_ids', locals: {tests: f.object.systemTests}
      end

      f.input :topics, :input_html => { 
        class: "select2",
        :onchange => "
          const $option = $(this);
          const questionBankChapterIds = [];

          $option.find(':selected').each((index, selectedOption) => {
            questionBankChapterIds.push(parseInt(selectedOption.value));
          });

          if (!questionBankChapterIds.length) {
            return;
          }

          const chapterIds = questionBankChapterIds.join(',');
          const url = `${window.location.origin}/chapters/populate_question_chapter_subtopic?question_bank_ids=${chapterIds}`;

          // get the topic & subtopic
          $.ajax({
            type: 'GET',
            url: url,
          }).done((data) => {
            const {topicId} = data.data;
            if(!!topicId) {
              const currentTopicId = parseInt($('#question_topicId').val());
              if(currentTopicId !== topicId) {
                // only fire the change event when the topicId is different
                $('#question_topicId').val(`${topicId}`).change();
              }
            }
          });
        "
      }, 
      :collection => Topic.name_with_subject, label: "Question Bank Chapters",
      hint: "Controls whether a question will appear in a chapter question bank for student or not" if current_admin_user.question_bank_owner?
      
      f.input :topic, :input_html => {  
        :class => "select2",
        :onchange => "
          const $option = $(this);
          const chapterId = $option.find(':selected').val();

          // if falsy value then return
          if (! (!!chapterId)){
            return;
          }

          const url = `${window.location.origin}/chapters/get_subtopics/${chapterId}/`;

          $.ajax({
            type: 'GET',
            url: url,
          }).done (function (data) {
            $('#question_subTopic_ids').empty();
            const subtopics = data.data;
            subtopics.forEach((item, _) => $('#question_subTopic_ids').append(`<option value=${item.id}>${item.name}</option>`));
          });
        "
      }, :collection => Topic.main_course_topic_name_with_subject + ((f.object.topicId.present? and f.object.topicId > 8000) ? Topic.topic_name_with_subject(f.object.topicId) : []), #crazy hack for now to get hindi course questions working which assumes topicId > 8000 must be for hindi course question
        label: "Question Chapter",
        hint: "Only for knowing chapter of the question but not shown to student except in chapter-wise test analysis" if current_admin_user.question_bank_owner?

      render partial: 'hidden_topic_ids', locals: {topics: f.object.topics} if current_admin_user.role != 'support'

      f.input :subTopics, input_html: { class: "select1" }, as: :select,
        :collection => SubTopic.topic_sub_topics(question.topicId != nil ? question.topicId : (question.topics.length > 0 ? question.topics.map(&:id) : [])),
        hint: "Hold Ctrl to select" if current_admin_user.question_bank_owner?

      f.input :type, as: :select, :collection => ["MCQ-SO", "MCQ-AR", "MCQ-MO", "SUBJECTIVE"]
      f.input :level, as: :select, :collection => ["BASIC-NCERT", "MASTER-NCERT"]
      f.input :paidAccess

      if current_admin_user.question_bank_owner?
        f.input :ncert
      end

      f.input :use_chapter, :input_html => {  
        :class => "select2",
        :value => "",
        :onchange => "
          const $option = $(this);
          const chapterId = $option.find(':selected').val();
          sessionStorage.setItem(`cross_chapterId`, chapterId);
        "
        }, :collection => Topic.main_course_topic_name_with_subject, 
        label: "Alternative NCERT sentence chapter",
        hint: "Select some chapter other than \"#{f.object&.topic&.name}\" to search ncert or video sentences in" if f.object.topicId.present?

      f.input :ncert_sentence_ids, 
        input_html: {id: "question_ncert_sentences_select2"}, 
        label: "NCERT Sentence", as: :selected_list, 
        # special handing for 'Mathematical Tools' chapter as that sentences in many other chapters of physics ncert book
        url: admin_ncert_sentences_path(q: f.object.topicId == 676 ? {noteId_in: [2796, 2800, 2802, 2803, 2804, 2805, 2806, 2843, 2877]} : {chapterId_eq: f.object.topicId}), 
        fields: [:sentence], 
        display_name: 'sentenceContext', 
        predicate: 'matches_regexp',
        minimum_input_length: 5 if f.object.topicId.present?

      f.input :video_sentence_ids, 
        input_html: {id: "question_video_sentences_select2"}, 
        label: "Video Sentence", as: :selected_list,
        order_by: 'videoId_asc_and_timestampStart_asc',
        fields: [:sentence, :sentence1],
        url: admin_video_sentences_path(q: {chapterId_eq: f.object.topicId}),
        display_name: 'sentenceContext', predicate: 'matches_regexp', 
        minimum_input_length: 5, 
        hint: raw("<a href='#{admin_videos_path(order: 'seqId_asc_and_id_asc', q: {videoTopics_chapterId_eq: f.object.topicId, language_eq: 'hinglish'})}' target='_blank'>Chapter Videos</a> List used for linking <br />Check <a href='#{admin_video_sentences_path(q: {similar_to_question: f.object.id})}' target='_blank'>Suggested Video Sentences</a> to link") if f.object.topicId.present?

      render partial: 'cross_chapter'
      render partial: 'question_edit'

      f.input :lock_version, :as => :hidden
      if current_admin_user.question_bank_owner?
        f.input :deleted
      end
      f.input :orignalQuestionId, as: :hidden, :input_html => { :value => params[:_source_id] }
    end
    f.has_many :details, new_record: true, allow_destroy: true do |detail|
      detail.inputs "Details" do
        detail.input :exam, as: :select, :collection => ["AIIMS", "AIPMT", "BOARD", "NEET", "PMT"]
        detail.input :year
      end
    end
    f.actions
  end
end
