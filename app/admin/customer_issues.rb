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

  remove_filter :topic, :question, :video, :user

  permit_params :resolved

  filter :topic_id_eq, as: :select, collection: -> { Topic.name_with_subject }, label: "Chapter"
  filter :user_id_eq, label: "User ID"
  preserve_default_filters!

  scope :botany_issues, show_count: true
  scope :chemistry_issues, show_count: true
  scope :physics_issues, show_count: true
  scope :zoology_issues, show_count: true

  form do |f|
    f.inputs "Issues" do
      f.input :resolved
    end
    f.actions
  end

  index do
    id_column
    column :description
    column ("Type") {|issue| CustomerIssueType.find(issue.typeId).displayName}
    column :question
    column :video
    column :note
    column :topic
    toggle_bool_column :resolved
    column :user
    actions
  end
end
