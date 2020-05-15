ActiveAdmin.register CustomerIssue do
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

  remove_filter :topic, :question, :video, :user, :test, :customer_issue_type

  permit_params :resolved

  filter :topic_id_eq, as: :select, collection: -> { Topic.name_with_subject }, label: "Chapter"
  filter :user_id_eq, label: "User ID"
  preserve_default_filters!

  scope "Open", :non_resolved, default: true
  scope :biology_test_issues, show_count: false
  scope :botany_test_issues, show_count: false
  scope :chemistry_test_issues, show_count: false
  scope :physics_test_issues, show_count: false
  scope :zoology_test_issues, show_count: false
  scope :full_tests, show_count: false
  scope :biology_masterclass, show_count: false
  scope :physics_masterclass, show_count: false
  scope :chemistry_masterclass, show_count: false
  scope :biology_masterclass_tests, show_count: false
  scope :botany_question_issues, show_count: false
  scope :chemistry_question_issues, show_count: false
  scope :physics_question_issues, show_count: false
  scope :zoology_question_issues, show_count: false
  scope :botany_video_issues, show_count: false
  scope :chemistry_video_issues, show_count: false
  scope :physics_video_issues, show_count: false
  scope :zoology_video_issues, show_count: false
  scope :all, :show_count => false

  form do |f|
    f.inputs "Issues" do
      f.input :resolved
    end
    f.actions
  end

  index do
    selectable_column
    id_column
    column :description
    column ("Type") {|issue| CustomerIssueType.find(issue.typeId).displayName}
    column :question
    column :video
    column :note
    column :topic
    column :test
    toggle_bool_column :resolved
    column :user
    actions
  end

  batch_action :resolve do |ids|
    batch_action_collection.find(ids).each do |customer_issue|
      customer_issue.resolved = true
      customer_issue.save
    end
    redirect_to collection_path, notice: "Resolved Issues."
  end

  action_item :see_unsolved_data, only: :index do
    link_to 'Pending Customer Issue Count', '../../customer_issues/pending_stats'
  end

  controller do
    def scoped_collection
      super.includes(:topic, :customer_issue_type, :user)
    end
  end
end
