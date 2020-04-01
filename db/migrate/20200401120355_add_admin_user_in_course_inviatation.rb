class AddAdminUserInCourseInviatation < ActiveRecord::Migration[5.2]
  def change
    add_column "CourseInvitation", "adminUserId", :integer, default: nil
  end
end
