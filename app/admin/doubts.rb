require 'base64'

ActiveAdmin.register Doubt do
  remove_filter :topic, :answers, :user
  permit_params :content, :deleted, :teacherReply, :imgUrl

  filter :topic_id_eq, as: :select, collection: -> { Topic.name_with_subject }, label: "Chapter"
  filter :id_eq, as: :number, label: "Doubt ID"
  filter :subject_name, as: :select, collection: -> {Subject.neetprep_course}, label: "Subject"
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

  action_item :see_unsolved_data, only: :index do
    link_to 'Pending Doubts Count', '../../doubts/pending_stats'
  end

  index do
    id_column
    column (:content) { |doubt| raw(doubt.content) }
    column :imgUrl do |doubt|
      raw('<img src="' + doubt.imgUrl + '" width="128" height="72">') if not doubt.imgUrl.blank?
    end
    column :createdAt
    column :topic
    column :tagType
    column :doubtType
    column :teacherReply
    column ("Link") {|doubt| raw('<a target="_blank" href="https://www.neetprep.com/subject/' + Base64.encode64("Doubt:" + doubt.topic.subjectId.to_s) + '/topic/' + Base64.encode64("Doubt:" + doubt.topic.id.to_s) + '/doubt/' + Base64.encode64("Doubt:" + doubt.id.to_s) + '">Answer on NEETprep</a>')}
      # + '/topic/' 
      # + Base64.encode64("Doubt:" + doubt.topic.id.to_s) 
      # + '/doubt/' 
      # + Base64.encode64("Doubt:" + doubt.id.to_s)
    actions
  end

end
