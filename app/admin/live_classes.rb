include ZoomHelper
include TeachMintHelper

ActiveAdmin.register LiveClass do
  # remove delete actions from show page by default and add it manually for live classes which haven't ended yet
  config.action_items.delete_if {|item| item.name == :destroy && item.display_on?(:show) }

  permit_params :roomName, :description, :startTime, :endTime, :paid, :zoomEmail, course_ids: []
  remove_filter :users, :courses

  before_destroy do |resource|
    # ensure room is deleted from the techmint services
    room_id = Base64.encode64(resource.roomName).gsub(/[^0-9A-Za-z]/, '')
    response = TeachMintService.remove_room(room_id)

    flash[:info] = response["msg"]
  end


  member_action :go_live, method: :post do
    begin
      # find if live class user exists otherwise create a new user
      live_class_user = LiveClassUser.find_or_create_by!(userId: current_admin_user.userId, liveClassId: resource.id, userType: 1)

      room_id = resource.room_id
      response = TeachMintService.create_room(resource.roomName, room_id)

      if response['status'] == true
        # add current user to the room
        inst = TeachMintService.new(room_id: room_id, user: User.find(current_admin_user.userId))
        room_url = inst.host_join

        redirect_to room_url
      end
    rescue => exception
      flash[:danger] = exception.to_s
      redirect_to action: :show
    end
  end

  member_action :delete_room, method: :delete do
    room_id = resource.room_id
    response = TeachMintService.remove_room(room_id)

    flash[:notice] = response["msg"]

    redirect_to action: :show
  end


  member_action :zoom_meeting, method: :post do
    zoom_service = ZoomService.new(resource)
    begin
      # if already have meeting id then only get join url
      start_url = resource.zoomMeetingId? ? zoom_service.get_join_url : zoom_service.create_meeting!
      redirect_to start_url
    rescue => exception
      flash[:danger] = exception.to_s
      redirect_to action: :show
    end
  end

  action_item :delete, only: :show, if: proc { resource.endTime > Time.now.utc } do 
    link_to "Delete", admin_live_class_path(resource), class: 'member_link', method: :delete
  end

  action_item :go_live, only: :show, if: proc { resource.endTime > Time.now.utc } do 
    link_to "Go live", go_live_admin_live_class_path(resource), class: 'member_link', method: :post, data: {confirm: "Are You sure ?"}, style: "background-color: #db8121;"
  end

  action_item :zoom_meeting, only: :show , if: proc { resource.endTime > Time.now.utc and not resource.zoomEmail.nil? } do
    link_to "Launch Zoom", zoom_meeting_admin_live_class_path(resource), class: 'member_link', method: :post, data: {confirm: "Are You sure ?"}, style: "background-color: #2181db;"
  end

  action_item :delete_room, only: :show do
    link_to "Remove Room", delete_room_admin_live_class_path(resource), class: 'member_link', method: :delete, data: {confirm: "Are You sure ?"}, style: "background-color: red;"
  end

  show do |f|
    attributes_table do
      row :id
      row :roomName
      row ("Description") do
        raw(f.description)
      end
      row ("Courses") do
        raw(f.courses.map { |c| "<a target='_blank' href='/admin/courses/#{c.id}'>#{c.name}</a>" }.join(","))
      end
      row :startTime
      row :endTime
      row :recordingUrl
      row ("Zoom Details") do
        unless f.zoomEmail.nil?
          raw("#{f.zoomEmail} (Meeting ID: <strong> #{f.zoomMeetingId || '-'} </strong>)")
        else
          "Empty"
        end
      end
      row :paid
    end
  end

  index do
    id_column
    column :roomName
    column :description
    column ("Course Name") {|lc| raw(lc.courses.map { |c| "<a target='_blank' href='/admin/courses/#{c.id}'>#{c.name}</a>" }.join(","))}
    column :startTime
    column :endTime
    column :zoomMeetingId

    toggle_bool_column :paid

    actions defaults: false do |lc|
      item "View", admin_live_class_path(lc), class: 'member_link', method: :get
      item "Edit", edit_admin_live_class_path(lc), class: 'member_link', method: :get
      if lc.endTime > Time.now.utc
        item "Delete", admin_live_class_path(lc), class: 'member_link', method: :delete
        item "Go live", go_live_admin_live_class_path(lc), class: 'member_link', method: :post, data: {confirm: "Are You sure ?"}, style: "background-color: #db8121;"
        item "Launch Zoom", zoom_meeting_admin_live_class_path(lc), class: 'member_link', method: :post, data: {confirm: "Are You sure ?"}, style: "background-color: #2181db;" unless lc.zoomEmail.nil?
      end
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "Live Classes" do
      render partial: 'ckeditor'
      text_node javascript_include_tag Ckeditor.cdn_url

      f.input :roomName,      label: "Room Name",       as: :string,          required: true
      f.input :recordingUrl,  label: "Recording Url",   as: :string,          required: false
      f.input :zoomEmail,     label: "Zoom Email",      as: :email,           required: false
      f.input :description,   label: "Description",     as: :ckeditor,        required: true
      f.input :courses,       label: "Select Course",   as: :select,          required: true, input_html: { class: "select2" }, collection: Course.live_classes, hint: "Hold Ctrl to select courses" 
      f.input :startTime,     label: "Start Time",      as: :datetime_picker, required: true
      f.input :endTime,       label: "End Time",        as: :datetime_picker, required: true
      f.input :paid,          label: "Paid Class",      as: :boolean,         required: true
    end
    f.actions
  end

end
