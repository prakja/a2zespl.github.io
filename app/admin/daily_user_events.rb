ActiveAdmin.register DailyUserEvent do

  actions :index

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :userId, :eventDate, :event, :eventCount, :courseId
  #
  # or
  #
  # permit_params do
  #   permitted = [:userId, :eventDate, :event, :eventCount, :courseId]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  

  scope :current_week, show_count: false
  scope "Past 4 weeks", :past_week, show_count: false

  index do
    id_column
    column ("User Id") { |e| raw("<a target='_blank' href='/admin/users/#{e.userId}'>#{e.userId}</a>")}
    column :event
    column :eventCount
    column :eventDate
    column ("Course Id") { |e| e.courseId.nil? ? '-' : raw("<a target='_blank' href='/admin/courses/#{e.courseId}'>#{e.courseId}</a>")}
  end
end
