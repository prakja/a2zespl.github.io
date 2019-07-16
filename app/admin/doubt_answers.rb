ActiveAdmin.register DoubtAnswer do
  permit_params :content, :deleted, :imgUrl
  remove_filter :doubt, :user

  filter :userId_eq, as: :number, label: "User ID"
  filter :doubtId_eq, as: :number, label: "Doubt ID"
  preserve_default_filters!

  index do
    id_column
    column (:content) {|doubt_answer| raw(doubt_answer.content)}
    column :doubt
    column :user
    column :deleted
    actions
  end

  form do |f|
    f.inputs "Doubt Answer" do
      f.input :content, as: :quill_editor
      f.input :deleted
    end
    f.actions
  end
end
