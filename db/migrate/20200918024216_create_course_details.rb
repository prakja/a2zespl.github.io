class CreateCourseDetails < ActiveRecord::Migration[5.2]
  def change
    create_table ("public.CourseDetail") do |t|
      t.integer :courseId, null: false
      t.string :description
      t.string :shortDescription
      t.float :rating
      t.integer :ratingCount
      t.integer :enrolled
      t.string :language, :default =>  "hinglish"
      t.string :videoUrl
      t.boolean :bestseller, :default =>  false
      t.jsonb :curriculum, :default =>  {}
      t.jsonb :features, :default =>  {}
      t.jsonb :requirements, :default =>  {}
      t.datetime :createdAt, null: false
      t.datetime :updatedAt, null: false
    end
    add_foreign_key "public.CourseDetail", "Course", column: :courseId, primary_key: "id"
  end
end
