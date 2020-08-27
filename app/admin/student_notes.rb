ActiveAdmin.register StudentNote do
  remove_filter :note, :question, :flashCard, :user
  preserve_default_filters!
  scope :all, show_count: false, default: true
  scope :questionNotes, show_count: false
  scope :flashCardNotes, show_count: false
  scope :ncertNotes, show_count: false
  index pagination_total: false do
    columns_to_exclude = []
    (StudentNote.column_names - columns_to_exclude).each do |c|
      row c.to_sym
    end
  end
end
