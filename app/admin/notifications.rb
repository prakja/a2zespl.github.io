ActiveAdmin.register Notification do
  remove_filter :user
  filter :userId_eq, as: :number, label: "User ID"
  preserve_default_filters!

  index do

    id_column
    column :title
    column :user
    column (:body) { |notification| raw(notification.body)  }
    column ("Doubt Link") { |notification|
      string_items = notification.body.split
      id = ""
      string_items.each do |item|
        if item.start_with?('http')
          id = item.split('/')[-1]
        end
      end
      link_to "Answer this doubt", "http://admin1.neetprep.com/doubt_answers/answer?doubt_id=" + id.to_s, target: ":_blank"
    }
    actions
  end
end
