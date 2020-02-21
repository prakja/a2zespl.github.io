ActiveAdmin.register Target do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :createdAt, :updatedAt, :userId, :score, :testId, :targetDate, :status, :maxMarks
  #
  # or
  #
  # permit_params do
  #   permitted = [:createdAt, :updatedAt, :userId, :score, :testId, :targetDate, :status, :maxMarks]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
  remove_filter :target_chapters, :user, :test
  preserve_default_filters!

  filter :userId_eq, as: :number, label: "User ID"

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
    column :testId
    column :maxMarks
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
