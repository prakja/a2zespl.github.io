class CreateStudentCoachs < ActiveRecord::Migration[5.2]
  def change
    create_table :student_coaches do |t|
      t.integer :studentId, null: false
      t.integer :coachId, null: false
      t.string :role, null: false

      t.timestamps
    end
    add_index :student_coaches, [:studentId, :coachId], unique: true
    add_foreign_key :student_coaches, :User, column: :studentId, primary_key: "id"
    add_foreign_key :student_coaches, "admin_users", column: :coachId, primary_key: "id"
  end
end
