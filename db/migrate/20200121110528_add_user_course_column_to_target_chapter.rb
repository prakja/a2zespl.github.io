class AddUserCourseColumnToTargetChapter < ActiveRecord::Migration[5.2]
  def change
    add_column "public.TargetChapter", "userCourseId", :integer, null: false
    #Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
  end
end
