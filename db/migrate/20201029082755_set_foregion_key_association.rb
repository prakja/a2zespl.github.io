class SetForegionKeyAssociation < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :version_associations, :versions, column: :version_id
  end
end
