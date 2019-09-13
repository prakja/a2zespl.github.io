require 'base64'

ActiveAdmin.register Doubt do
  config.sort_order = 'createdAt_desc'
  remove_filter :topic, :answers, :user, :question, :doubt_admin
  permit_params :content, :deleted, :teacherReply, :imgUrl

  filter :topic_id_eq, as: :select, collection: -> { Topic.name_with_subject }, label: "Chapter"
  filter :id_eq, as: :number, label: "Doubt ID"
  filter :userId_eq, as: :number, label: "User ID"
  filter :subject_name, as: :select, collection: -> {Subject.subject_names}, label: "Subject"
  filter :solved, as: :select, collection: ["yes", "no"]
  filter :paid, as: :select, collection: ["yes", "no"]
  filter :student_name, as: :string
  filter :student_email, as: :string
  filter :student_phone, as: :string
  preserve_default_filters!

  scope :botany_paid_student_doubts
  scope :chemistry_paid_student_doubts
  scope :physics_paid_student_doubts
  scope :zoology_paid_student_doubts

  form do |f|
    f.inputs "Doubt" do
      f.input :deleted
    end
    f.actions
  end

  filter :admin_user, as: :select, collection: -> { AdminUser.distinct_faculty_email_id }, label: "Admin User"
  preserve_default_filters!

  batch_action :assign_doubts, form: {
    assignTo: AdminUser.distinct_faculty_name
  } do |ids, inputs| 
    assign_to = inputs['assignTo']
    p ids
    p assign_to
    admin_user_id = AdminUser.where(email: assign_to).first.id
    ids.each do |id|
      doubt = Doubt.find(id)
      if not doubt.doubt_admin.blank?
        next
      end
      doubt_admin = DoubtAdmin.new()
      doubt_admin[:doubtId] = id
      doubt_admin[:admin_user_id] = admin_user_id
      doubt_admin[:created_at] = Time.now
      doubt_admin[:created_at] = Time.now
      doubt_admin.save
    end
  end

  batch_action :unassign_doubts do |ids|
    ids.each do |id|
      doubt = Doubt.find(id)
      if doubt.doubt_admin.blank?
        next
      end
      doubt.doubt_admin.delete
    end
  end

  action_item :see_unsolved_data, only: :index do
    link_to 'Pending Doubts Count', '../../doubts/pending_stats'
  end

  index do
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
    column "adminUser" do |doubt|
      doubt.admin_user.email if not doubt.admin_user.blank?
    end
    #column ("Link") {|doubt| raw('<a target="_blank" href="https://www.neetprep.com/subject/' + Base64.encode64("Doubt:" + doubt.topic.subjectId.to_s) + '/topic/' + Base64.encode64("Doubt:" + doubt.topic.id.to_s) + '/doubt/' + Base64.encode64("Doubt:" + doubt.id.to_s) + '">Answer on NEETprep</a>')}
    column ("Link") {|doubt| link_to "Answer this doubt", '/doubt_answers/answer?doubt_id=' + doubt.id.to_s, target: ":_blank" }
      # + '/topic/' 
      # + Base64.encode64("Doubt:" + doubt.topic.id.to_s) 
      # + '/doubt/' 
      # + Base64.encode64("Doubt:" + doubt.id.to_s)
    actions
  end

end
