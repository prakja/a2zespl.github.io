ActiveAdmin.register StudentNote do
  remove_filter :note, :question, :flashCard, :user
  preserve_default_filters!
  scope :all, show_count: false, default: true
  scope :questionNotes, show_count: false
  scope :flashCardNotes, show_count: false
  scope :ncertNotes, show_count: false

  index pagination_total: true do
    id_column
    columns_to_exclude = ["id"]
    (StudentNote.column_names - columns_to_exclude).each do |c|
      column c.to_sym
    end
    actions
  end

  show do
    attributes_table do
      StudentNote.column_names.each do |c|
        row c.to_sym
      end

      row ('Attachment Image') { |r| raw("<img id='student-attach-img' src='#{r.studentAttachImgUri}' />")} unless student_note.studentAttachImgUri.nil?
    end
    render partial: 'image_viewer', locals: {:imageId => 'student-attach-img'} unless student_note.studentAttachImgUri.nil?
    active_admin_comments
  end
  
end
