class AddColumnToTargetChapter < ActiveRecord::Migration[5.2]
  def change
    add_column "public.TargetChapter", :startedAt, :datetime, null: false
    #Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
  end
end
