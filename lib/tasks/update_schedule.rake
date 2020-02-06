namespace :update do
  desc "This take does something useful!"

  # [].insert(at, what)
  task :english_schedule => :environment do
    new_order_chapter_list = 
    "7889|Read NCERT Chapter|3,7889|Watch NEETprep Videos & Take Notes|8,7889|Practice Questions & Revision|1,7889|Live Session|1,7891|Read NCERT Chapter|3,7891|Watch NEETprep Videos & Take Notes|12,7891|Practice Questions & Revision|5,7891|Live Session|1,7876|Read NCERT Chapter|4,7876|Watch NEETprep Videos & Take Notes|8,7876|Practice Questions & Revision|6,7876|Live Session|1,7879|Read NCERT Chapter|3,7879|Watch NEETprep Videos & Take Notes|8,7879|Practice Questions & Revision|5,7879|Live Session|1".split(",")
    # new_order_chapter_list_stripted
    # new_order_chapter_list.each do |item|
    #   item_split = item.split("|")
    #   item_split.map!(&:strip)

    # end
    # p new_order_chapter_list
    hours_per_day = ScheduleItem.where(['"scheduleId" = ? and "topicId" in (?)', 4, [7876, 7879, 7889, 7891]]).group_by_day(:scheduledAt).sum(:hours)
    # p hours_per_day
    sum_hours_day = 0
    hours_per_day.each do |per_day|
      sum_hours_day += per_day[1].to_i
    end
    Rails.logger.info "Available: " + sum_hours_day.to_s

    task_hours = 0
    new_order_chapter_list.each do |item|
      task_row = item.split("|")
      task_hours += task_row[2].to_i
    end
    Rails.logger.info "Task hours: " + task_hours.to_s

    hours_per_day.each do |per_day|
      hours_available = per_day[1]
      date = per_day[0]
      while hours_available != 0
        task_row_raw = new_order_chapter_list.first
        # p task_row_raw, hours_available
        task_row = task_row_raw.split("|")
        task_row.map!(&:strip)
        new_order_chapter_list.delete_at(0)
        # delete if processed
        task_hours = task_row[2].to_i
        task_name = task_row[1]
        task_chapter = task_row[0]
        final_hours = 0
        if task_hours == hours_available
          final_hours = task_hours
          Rails.logger.info "Create: " + date.to_s + " " + task_chapter + " " + task_name + " " + (task_hours).to_s
          hours_available = 0
        elsif task_hours > hours_available
          final_hours = hours_available
          Rails.logger.info "Create: " + date.to_s + " " + task_chapter + " " + task_name + " " + (hours_available).to_s
          task_hours = task_hours - hours_available
          new_order_chapter_list.insert(0, [task_chapter, task_name, task_hours.to_s].join("|"))
          hours_available = 0
        elsif task_hours < hours_available
          final_hours = task_hours
          Rails.logger.info "Create: " + date.to_s + " " + task_chapter + " " + task_name + " " + (task_hours).to_s
          hours_available = hours_available - task_hours
        end
        ScheduleItem.create({
          :createdAt => Time.now,
          :updatedAt => Time.now,
          :name => task_name,
          :scheduledAt => DateTime.parse(date.to_s).at_noon,
          :topicId => task_chapter,
          :scheduleId => 4,
          :hours => final_hours
        })
      end
    end
  end
end
