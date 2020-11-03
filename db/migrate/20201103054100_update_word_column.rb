class UpdateWordColumn < ActiveRecord::Migration[5.2]
  def change
    add_index "Glossary", "word", unique: true
    #Ex:- add_index("admin_users", "username")
  end
end
