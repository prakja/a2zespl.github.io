class CreateStudentOnboardingEvents < ActiveRecord::Migration[5.2]
  def change
    create_table "StudentOnboardingEvents" do |t|
      t.datetime :createdAt, null: false
      t.datetime :updatedAt, null: false
      t.integer :userId
      t.string :description
    end
    add_foreign_key "StudentOnboardingEvents", "User", column: :userId, primary_key: "id"
  end
end
