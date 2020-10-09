ActiveAdmin.register Target do
  
  remove_filter :target_chapters, :user, :test
  preserve_default_filters!

  permit_params :createdAt, :updatedAt, :userId, :score, :testId, :targetDate, :status, :maxMarks, :testType

  filter :userId_eq, as: :number, label: "User ID"

  form do |f|
    f.object.updatedAt = Time.now
    f.inputs "Target" do
      f.input :userId
      f.input :score
      f.input :testId
      f.input :targetDate, as: :date_picker
      f.input :status, as: :select, :collection => ["active", "complete", "abandoned"]
      f.input :maxMarks
      f.input :testType
    end
    f.actions
  end

  index do
    id_column
    column :user
    column ("Targeted Score") { |target| target.score }
    column ("Scored") { |target|
     if not target.test.nil?
       test = target.test
       test_attempt = test.test_attempt(target.userId)
       if not test_attempt.nil?
         result_hash = test_attempt.result
         p result_hash
         score = result_hash["totalMarks"]
         raw('<p>' + score.to_s + '</p>')
       end
     end
    }
    column :test
    column :maxMarks
    column :testType
    column ("Target Chapters") { |target|
     target_id = target.id
     target_chapters = target.target_chapters.includes(:chapter).limit(5)
     all_target_chapters_count = target.target_chapters.count
     chapters = ""
     target_chapters.each do |target_chapter|
       chapters += '<p>' + target_chapter.chapter.name + '</p>'
     end
     raw('<a href="/admin/target_chapters?q[targetId_eq]=' + target_id.to_s + '">Count: '  + all_target_chapters_count.to_s + '</a>' + chapters)
    }
    column :status
    actions
  end
end
