ActiveAdmin.register StudentNote do
  remove_filter :note, :question, :flashCard, :user
  preserve_default_filters!
  scope :all, show_count: false, default: true
  scope :questionNotes, show_count: false
  scope :flashCardNotes, show_count: false
  scope :ncertNotes, show_count: false
  index pagination_total: false do
    id_column
    columns_to_exclude = ["id"]
    (StudentNote.column_names - columns_to_exclude).each do |c|
      column c.to_sym
    end
    actions
  end
end
