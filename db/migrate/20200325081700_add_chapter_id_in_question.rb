class AddChapterIdInQuestion < ActiveRecord::Migration[5.2]
  def change
    add_column "Question", "topicId", :integer, default: nil
  end
end
