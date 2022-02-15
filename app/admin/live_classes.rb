include TechMintHelper

ActiveAdmin.register LiveClass do
  permit_params :roomName, :description, :startTime, :endTime, :paid, course_ids: []

  before_destroy do |resource|
    # ensure room is deleted from the techmint services
    room_id = Base64.encode64(resource.roomName).gsub(/[^0-9A-Za-z]/, '')
    response = TechMintService.create_room(resource.roomName, room_id)

    flash[:notice] = response["msg"]
  end

  member_action :go_live, method: :post do
    begin
      # find if live class user exists otherwise create a new user
      live_class_user = LiveClassUser.find_or_create_by!(userId: current_admin_user.userId, liveClassId: resource.id, userType: 1)

      # get room_id from base64 of room name and remove all special characters
      room_id = Base64.encode64(resource.roomName).gsub(/[^0-9A-Za-z]/, '')
      response = TechMintService.create_room(resource.roomName, room_id)

      if response['status'] == true
        # add current user to the room
        inst = TechMintService.new(room_id: room_id, user: User.find(current_admin_user.userId))
        room_url = inst.host_join

        redirect_to room_url
      end
    rescue => exception
      flash[:danger] = exception.to_s
      redirect_to action: :show
    end
  end

  member_action :delete_room, method: :delete do
    room_id = Base64.encode64(resource.roomName).gsub(/[^0-9A-Za-z]/, '')
    response = TechMintService.remove_room(room_id)

    flash[:notice] = response["msg"]

    redirect_to action: :show
  end

  action_item :go_live, only: :show do
    link_to "Go live", go_live_admin_live_class_path(resource), class: 'member_link', method: :post, data: {confirm: "Are You sure ?"}, style: "background-color: #2181db;"
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

    toggle_bool_column :paid

    actions defaults: true do |lc|
      item "Go live", go_live_admin_live_class_path(lc), class: 'member_link', method: :post, 
        data: {confirm: "Are You sure ?"}, style: "background-color: #2181db;"
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "Live Classes" do
      render partial: 'ckeditor'
      text_node javascript_include_tag Ckeditor.cdn_url

      f.input :roomName,    label: "Room Name",     as: :string,          required: true
      f.input :description, label: "Description",   as: :ckeditor,        required: true
      f.input :courses,    label: "Select Course", as: :select,          required: true, input_html: { class: "select2" },
        collection: Course.all,
        hint: "Hold Ctrl to select" 
      f.input :startTime,   label: "Start Time",    as: :datetime_picker, required: true
      f.input :endTime,     label: "End Time",      as: :datetime_picker, required: true
      f.input :paid,        label: "Paid Class",    as: :boolean,         required: true
    end
    f.actions
  end

end
