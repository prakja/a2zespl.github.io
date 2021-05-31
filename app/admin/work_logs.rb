ActiveAdmin.register WorkLog do
  actions :all, :except => [:destroy]
  permit_params :start_time, :end_time, :total_hours, :content
  remove_filter :start_time, :end_time, :total_hours, :content, :versions

  scope :my_logs, show_count: false do |log|
    log.my_logs(current_admin_user)
  end

  before_create do |work_log|
    work_log.admin_user_id ||= current_admin_user.id
    work_log.date ||= Date.today.to_s
  end

  index do
    selectable_column
    id_column
    column :date
    column :created_by do |log| 
      user = log.created_by
      raw("<a target='_blank' href='../admin/users/#{user.id.to_s}/'>#{user.email}</a>")
    end
    column :actions do |item|
      links = []
      links << link_to('Show', admin_work_log_path(item))
      links << link_to('Edit', edit_admin_work_log_path(item)) if item.admin_user_id == current_admin_user.id
      links.join('  ').html_safe
    end
  end

  show do
    render 'can_edit', { isSame: (work_log.admin_user_id == current_admin_user.id)} # an ugly hack to hide Edit button on show page if another admin user views the log
    attributes_table do
      row ('start_time') {|c| c.start_time.strftime("%I:%M%p")}
      row ('end_time') {|c| c.end_time.strftime("%I:%M%p") }
      row :total_hours
      row :date
      row ('content') {|c| raw(c.content) }
      row :created_by do |log| 
        user = log.created_by
        raw("<a target='_blank' href='../admin/users/#{user.id.to_s}/'>#{user.email}</a>")
      end
    end
    active_admin_comments
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.object.date = Date.today.to_s
    f.inputs "Work Log" do
      render partial: 'tinymce', :locals => {new: f.object.new_record?}
      f.input :date, input_html: { readonly: true, disabled: true  }, as: :string
      f.input :start_time, :as => :time_select, :placeholder => "HH:MM", :step => :thirty_minutes, input_html: {required: true}
      f.input :end_time, :as => :time_select, :placeholder => "HH:MM", :step => :thirty_minutes, input_html: {required: true}
      f.input :total_hours, :as => :select, :collection => (0..12).to_a
      f.input :content
    end
    f.actions
    render 'misc', {disableUpdate: !f.object.new_record? ? (f.object.admin_user_id != current_admin_user.id) : false}
  end
end
