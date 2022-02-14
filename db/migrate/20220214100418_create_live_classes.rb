class CreateLiveClasses < ActiveRecord::Migration[5.2]
  def change
    create_table :LiveClasses do |t|
      t.string   :roomId
      t.text     :description
      t.integer  :courseId
      t.datetime :startTime
      t.datetime :endTime
      t.boolean  :paid, default: true

      t.datetime :createdAt, null: false
      t.datetime :updatedAt, null: false
    end

    add_foreign_key :LiveClasses, :Course, column: :courseId, primary_key: :id

    create_table :LiveClassUser do |t|
      t.integer  :liveClassId, null: false
      t.integer  :userId,      null: false
      t.datetime :createdAt,   null: false
      t.datetime :updatedAt,   null: false
    end

    add_foreign_key :LiveClassUser, :User,        column: :userId,      primary_key: :id
    add_foreign_key :LiveClassUser, :LiveClasses, column: :liveClassId, primary_key: :id
  end
end
