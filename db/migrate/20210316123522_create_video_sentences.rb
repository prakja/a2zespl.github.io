class CreateVideoSentences < ActiveRecord::Migration[5.2]
  def change
    create_table ("public.VideoSentence") do |t|
      t.integer :videoId
      t.integer :chapterId
      t.integer :sectionId
      t.string :sentence
      t.float :timestampStart
      t.float :timestampEnd
      t.datetime :createdAt, null: false
      t.datetime :updatedAt, null: false
    end
    add_foreign_key "public.VideoSentence", "Video", column: :videoId, primary_key: "id"
    add_foreign_key "public.VideoSentence", "Topic", column: :chapterId, primary_key: "id"
    add_foreign_key "public.VideoSentence", "Section", column: :sectionId, primary_key: "id"

  end
end
