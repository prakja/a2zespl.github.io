class AddAllowPracticeTest < ActiveRecord::Migration[5.2]
  def change
    add_column :Test, :allowPracticeMode, :boolean, :default => true
  end
end
