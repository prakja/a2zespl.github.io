namespace :update do
  desc "This take does something useful!"

  # [].insert(at, what)
  task :english_schedule => :environment do
    new_order_chapter_list = 
    "7815|Read NCERT Chapter|2,
    7815|Watch NEETprep Videos & Take Notes|11,
    7815|Practice Questions & Revision|6,
    7815|Live Session|2,
    7822|Read NCERT Chapter|2,
    7822|Watch NEETprep Videos & Take Notes|4,
    7822|Practice Questions & Revision|4,
    7822|Live Session|2,
    7826|Read NCERT Chapter|2,
    7826|Watch NEETprep Videos & Take Notes|13,
    7826|Practice Questions & Revision|6,
    7826|Live Session|2,
    7811|Read NCERT Chapter|4,
    7811|Watch NEETprep Videos & Take Notes|11,
    7811|Practice Questions & Revision|6,
    7811|Live Session|2,
    7816|Read NCERT Chapter|3,
    7816|Watch NEETprep Videos & Take Notes|12,
    7816|Practice Questions & Revision|6,
    7816|Live Session|2,
    7801|Read NCERT Chapter|3,
    7801|Watch NEETprep Videos & Take Notes|10,
    7801|Practice Questions & Revision|5,
    7801|Live Session|2,
    7805|Read NCERT Chapter|2,
    7805|Watch NEETprep Videos & Take Notes|10,
    7805|Practice Questions & Revision|6,
    7805|Live Session|2,
    7808|Read NCERT Chapter|3,
    7808|Watch NEETprep Videos & Take Notes|8,
    7808|Practice Questions & Revision|5,
    7808|Live Session|2,
    7813|Read NCERT Chapter|5,
    7813|Watch NEETprep Videos & Take Notes|17,
    7813|Practice Questions & Revision|10,
    7813|Live Session|2".split(",")

    # new_order_chapter_list_stripted
    # new_order_chapter_list.each do |item|
    #   item_split = item.split("|")
    #   item_split.map!(&:strip)

    # end
    # p new_order_chapter_list
    hours_per_day = ScheduleItem.where(['"scheduleId" = ? and "topicId" in (?)', 4, [7815,7815,7815,7815,7822,7822,7822,7822,7826,7826,7826,7826,7811,7811,7811,7811,7816,7816,7816,7816,7801,7801,7801,7801,7805,7805,7805,7805,7808,7808,7808,7808,7813,7813,7813,7813]]).group_by_day(:scheduledAt, range: 1.day.from_now.midnight...Date.parse("27-04-2020").midnight).sum(:hours)
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
          :hours: => final_hours
        })
      end
    end
  end
end