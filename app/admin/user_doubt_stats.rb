ActiveAdmin.register UserDoubtStat do
  config.sort_order = "doubt7DaysCount_desc"

  actions :index

  remove_filter  :user

  scope :paid_students, show_count: false, default: false
  scope :all, show_count: false

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
