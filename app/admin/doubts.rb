require 'base64'

ActiveAdmin.register Doubt do
  config.sort_order = 'createdAt_desc'
  remove_filter :topic, :answers, :user, :question, :doubt_admin, :versions, :user_doubt_stat
  permit_params :content, :deleted, :teacherReply, :imgUrl, :goodFlag

  filter :topic_id_eq, as: :searchable_select, collection: -> { Topic.name_with_subject }, label: "Chapter"
  filter :id_eq, as: :number, label: "Doubt ID"
  filter :userId_eq, as: :number, label: "User ID"
  filter :course_name, as: :searchable_select, collection: -> {Course.course_names}, label: "Course"
  filter :subject_name, as: :searchable_select, collection: -> {Subject.subject_names}, label: "Subject"
  filter :solved, as: :select, collection: ["yes", "no"]
  filter :paid, as: :select, collection: ["yes", "no"]
  filter :student_name, as: :string
  filter :student_email, as: :string
  filter :student_phone, as: :string
  preserve_default_filters!

  scope :chemistry_paid_student_doubts, show_count: false, default: true
  scope :botany_paid_student_doubts, show_count: false  
  scope :physics_paid_student_doubts, show_count: false
  scope :zoology_paid_student_doubts, show_count: false
  scope :masterclass_paid_student_doubts, show_count: false
  scope :all, show_count: false
  scope :concept_building_student_doubts, show_count: false
  # if current_admin_user.role == "admin"
  #   scope :all
  # end

  action_item :answer_this_doubt, only: :show do
    link_to 'Answer this doubt', "/doubt_answers/answer?doubt_id=" + resource.id.to_s, target: "_blank"
  end

  form do |f|
    f.inputs "Doubt" do
      f.input :deleted
    end
    f.actions
  end

  filter :admin_user, as: :searchable_select, collection: proc { AdminUser.distinct_faculty_name_id }, label: "Admin User"
  preserve_default_filters!

  batch_action :assign_doubts, form: -> do {
    assignTo: AdminUser.where(role: "faculty").distinct_faculty_name(current_admin_user.email)
  } end do |ids, inputs|
    assign_to = inputs['assignTo']
    p ids
    p assign_to
    admin_user_id = AdminUser.where(email: assign_to).first.id
    ids.each do |id|
      current_unsoved_unassigned_count = Doubt.where(id: DoubtAdmin.where(admin_user_id: admin_user_id).pluck(:doubtId)).solved('no').count
      p "Current count: " + current_unsoved_unassigned_count.to_s
      if current_unsoved_unassigned_count.to_i < 1
        doubt = Doubt.find(id)
        if doubt.doubt_admin.blank?
          doubt_admin = DoubtAdmin.new()
          doubt_admin[:doubtId] = id
          doubt_admin[:admin_user_id] = admin_user_id
          doubt_admin[:created_at] = Time.now
          doubt_admin[:created_at] = Time.now
          doubt_admin.save
        else
          p "Already assigned!"
        end
      else
        p "not assigning coz not blank or max count reached: " + current_unsoved_unassigned_count.to_s
      end
    end
  end

  batch_action :unassign_doubts do |ids|
    ids.each do |id|
      doubt = Doubt.find(id)
      if doubt.doubt_admin.blank?
        next
      else
        if current_admin_user.role == 'faculty' and current_admin_user.id != doubt.doubt_admin.admin_user_id
          p "Cannot unassign someone else doubt!"
          flash.now[:error] = "Cannot unassign someone else doubt!"
        else
          p "Unassigning doubts"
          doubt.doubt_admin.delete
        end
      end
    end
  end

  batch_action :delete_flag do |ids|
    batch_action_collection.find(ids).each do |doubt|
      doubt.deleted = true
      doubt.save
    end
    redirect_to collection_path, alert: "The Doubts have been deleted."
  end

  action_item :see_unsolved_data, only: :index do
    link_to 'Pending Doubts Count', '../../doubts/pending_stats'
  end

  index do
    render partial: 'img_css'
    selectable_column
    id_column
    column (:content) { |doubt| raw(doubt.content) }
    column :imgUrl do |doubt|
      raw('<img src="' + doubt.imgUrl + '" width="128" height="72">') if not doubt.imgUrl.blank?
    end
    column :createdAt
    column :topic
    column :tagType
    column :doubtType
    column :user
    column :week_doubt_count, :sortable => true
    column ("Link") {|doubt| link_to "Answer this doubt", '/doubt_answers/answer?doubt_id=' + doubt.id.to_s, target: ":_blank" }
      if current_admin_user.role == 'admin' or current_admin_user.role == 'faculty'
      toggle_bool_column :goodFlag
      else
      column :goodFlag
      end
      # + '/topic/'
      # + Base64.encode64("Doubt:" + doubt.topic.id.to_s)
      # + '/doubt/'
      # + Base64.encode64("Doubt:" + doubt.id.to_s)
    column "rank" do |doubt|
      doubt.user&.common_rank&.rank
    end
    column "subject rank" do |doubt|
      doubt.user&.subject_rank.map { |subjectRank| subjectRank.subject.name.to_s + "(" + subjectRank.rank.to_s + ")" }.compact
    end
    column "subject accuracy" do |doubt|
      doubt.user&.subject_rank.map { |subjectRank| subjectRank.subject.name.to_s + "(" + subjectRank.accuracy.to_s + "%)" }.compact
    end
    column "adminUser" do |doubt|
      doubt.admin_user.email if not doubt.admin_user.blank?
    end
    #column ("Link") {|doubt| raw('<a target="_blank" href="https://www.neetprep.com/subject/' + Base64.encode64("Doubt:" + doubt.topic.subjectId.to_s) + '/topic/' + Base64.encode64("Doubt:" + doubt.topic.id.to_s) + '/doubt/' + Base64.encode64("Doubt:" + doubt.id.to_s) + '">Answer on NEETprep</a>')}
    actions
  end

  controller do
    def scoped_collection
      if params[:scope] == 'all'
        params[:order] = 'createdAt_desc'
      end
      if (params[:scope].present? and params[:scope] != 'all') or params[:scope].nil?
        params[:order] = 'week_doubt_count_asc_and_createdAt_asc' if params[:order].blank?
        super.left_outer_joins(:user_doubt_stat).select('"Doubt".*, sum("UserDoubtStat"."doubt7DaysCount") as "week_doubt_count"').group('"Doubt"."id"').preload(:admin_user, :topic, user: [:common_rank, :user_profile, subject_rank: :subject])
      else
        super.preload(:topic, :admin_user, user: [:common_rank, :user_profile, subject_rank: :subject])
      end
    end
  end

end
