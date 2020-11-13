ActiveAdmin.register Target do
  
  remove_filter :target_chapters, :user, :test, :versions
  preserve_default_filters!

  permit_params :createdAt, :updatedAt, :userId, :score, :testId, :targetDate, :status, :maxMarks, :testType, target_chapters_attributes: [:_destroy]

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

  member_action :history do
    @target = Target.find(params[:id])
    @versions = PaperTrail::Version.where(item_type: 'Target', item_id: @target.id).order(created_at: :asc)
    @actions = []
    size = @versions.count - 1
    @versions.each_with_index do |version, index|
      next_version = @versions[index+1] if index <= size
      if not next_version.nil? 
        target_chapter_versions = PaperTrail::Version.where(item_type: "TargetChapter", created_at: version.created_at..next_version.created_at, whodunnit: version.whodunnit)
        temp = {
          version_id: version[:id],
          item_type: version[:item_type],
          item_id: version[:item_id],
          created_at: version[:created_at],
          event: version[:event],
          object: version[:object],
          whodunnit_type: version[:whodunnit_type],
          whodunnit: version[:whodunnit],
          actions: []
        }
        target_chapter_versions.each do |target_chapter_version|
          topic = Topic.find(VersionAssociation.where(version_id: target_chapter_version, foreign_type: "Topic").pluck(:foreign_key_id).first())
          temp[:actions] << {
            action: target_chapter_version[:event],
            chapter: topic[:name]
          }
        end
        @actions << temp
      else
        target_chapter_versions = PaperTrail::Version.where(item_type: "TargetChapter", created_at: version.created_at..version.created_at+1.days, whodunnit: version.whodunnit)
        temp = {
          version_id: version[:id],
          item_type: version[:item_type],
          item_id: version[:item_id],
          created_at: version[:created_at],
          event: version[:event],
          object: version[:object],
          whodunnit_type: version[:whodunnit_type],
          whodunnit: version[:whodunnit],
          actions: []
        }
        target_chapter_versions.each do |target_chapter_version|
          topic = Topic.find(VersionAssociation.where(version_id: target_chapter_version, foreign_type: "Topic").pluck(:foreign_key_id).first())
          temp[:actions] << {
            action: target_chapter_version[:event],
            chapter: topic[:name]
          }
        end
        @actions << temp
      end
    end
    p @actions
    render "layouts/target_history"
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
    column ("History") {|target| raw('<a target="_blank" href="/admin/targets/' + (target.id).to_s + '/history">View History</a>')}
    actions
  end
end
