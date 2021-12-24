ActiveAdmin.register UserChatAuthToken do
  preserve_default_filters!

  remove_filter :user
  filter :userId_eq, as: :number, label: "User Id"
  permit_params :userId, :authToken, :createdAt, :updatedAt, :defaultGroupId

  index do
    id_column
    column :user
    column :authToken
    column :defaultGroupId
    column :createdAt
    column :updatedAt
    actions
  end

  form do |f|
    f.inputs "User Chat Auth Token" do
      f.input :userId, :label => 'User ID', input_html: {required: true, disabled: (not f.object.new_record?)}
      f.input :authToken, :label => 'Auth Token', input_html: {required: true}, :include_blank => false
      f.input :defaultGroupId, :label => 'Default Group ID'
    end
    f.actions
  end

end
