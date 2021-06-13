ActiveAdmin.register UserDoubtStat do
  config.sort_order = "doubt7DaysCount_desc"

  actions :index

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :userId, :doubtCount, :doubt7DaysCount
  #
  # or
  #
  # permit_params do
  #   permitted = [:userId, :doubtCount, :doubt7DaysCount]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  remove_filter  :user

  index do
    column :user
    column :doubt7DaysCount, sortable: true do |d| 
      d.doubt7DaysCount
    end
    column :doubtCount, sortable: true do |d| 
      d.doubtCount
    end
  end
end
