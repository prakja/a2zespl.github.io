include TechMintHelper

ActiveAdmin.register LiveClass do
  permit_params :roomId, :description, :courseId, :startTime, :endTime, :paid

  before_destroy do |resource|
    # ensure room is deleted from the techmint services
    TechMintService.remove_room(resource.room_id) unless resource.room_id.nil?
  end

  member_action :go_live, method: :post do
    redirect_to admin_video_links_url
  end
  
  index do
    id_column
    column :roomId
    column :description
    column ("Course Name") {|lc| raw("<a target='_blank' href='/admin/courses/#{lc.courseId}'>#{Course.find(lc.courseId).name}</a>")}
    column :startTime
    column :endTime

    toggle_bool_column :paid

    actions defaults: true do |lc|
      item "Go live", go_live_admin_live_class_path(lc), class: 'member_link', method: :post, 
        data: {confirm: "Are You sure ?"}, style: "background-color: #2181db;"
    end
  end

  form do |f|
    f.inputs "Live Classes" do
      render partial: 'ckeditor'
      text_node javascript_include_tag Ckeditor.cdn_url

      f.input :roomId,      label: "Room Name",     as: :string,          required: true
      f.input :description, label: "Description",   as: :ckeditor,        required: true
      f.input :courseId,    label: "Select Course", as: :select,          required: true, :collection => Course.course_names
      f.input :startTime,   label: "Start Time",    as: :datetime_picker, required: true
      f.input :endTime,     label: "End Time",      as: :datetime_picker, required: true
      f.input :paid,        label: "Paid Class",    as: :boolean,         required: true
    end
    f.actions
  end

end
