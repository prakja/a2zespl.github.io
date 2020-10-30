class AddWhodunnitType < ActiveRecord::Migration[5.2]
  def change
    add_column :versions, :whodunnit_type, :string, :default => "admin"
  end
end
