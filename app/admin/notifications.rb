ActiveAdmin.register Notification do
  remove_filter :user
  filter :userId_eq, as: :number, label: "User ID"
  preserve_default_filters!

  index pagination_total: false do
    id_column
    column :title
    column :user
    column (:body) { |notification| raw(notification.body)  }
    column ("Doubt Link") { |notification|
      if notification.contextType == "Doubt" || notification.contextType == "DoubtAnswer" || notification.title.start_with?("New Doubt")
        string_items = notification.body.split
        id = ""
        string_items.each do |item|
          if item.start_with?('http')
            id = item.split('/')[-1]
          end
        end

        if not id == nil
          int_return = Integer(id) rescue false
          if int_return == false
            int_id = Base64.decode64(id)
            link_to "Answer this doubt", "/doubt_answers/answer?doubt_id=" + int_id.split(':')[1], target: ":_blank"
          else
            link_to "Answer this doubt", "/doubt_answers/answer?doubt_id=" + id.to_s, target: ":_blank"
          end
        else
          link_to "", "", target: ":_blank"
        end
      end
    }
    actions
  end
end
