class CourseInvitationForeignkey < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key "CourseInvitation", "admin_users", column: :adminUserId, primary_key: "id"
  end
end
