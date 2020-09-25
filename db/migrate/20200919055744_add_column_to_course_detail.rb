class AddColumnToCourseDetail < ActiveRecord::Migration[5.2]
  def change
    add_column "CourseDetail", "bannerImage", :string
    add_column "CourseDetail", "showTrial", :boolean, :default => false
    #Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
    #Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
  end
end
