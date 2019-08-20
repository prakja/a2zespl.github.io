class CreateDoubtAdmins < ActiveRecord::Migration[5.2]
  def change
    create_table :doubt_admins do |t|
      t.integer :doubtId
      t.belongs_to :admin_user
      t.timestamps
    end
    add_foreign_key :doubt_admins, :Doubt, column: :doubtId, primary_key: "id"
    add_index :doubt_admins, :doubtId, unique: true
  end
end
