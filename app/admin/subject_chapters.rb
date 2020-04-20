ActiveAdmin.register SubjectChapter do
  remove_filter :subject, :topic
  permit_params :deleted
  index do
    selectable_column
    id_column
    column ("Subject") { |sc|
      auto_link(sc.subject)
    }
    column ("Chapter") {|sc|
      auto_link(sc.topic)
    }
    toggle_bool_column :deleted
  end
  controller do
    def scoped_collection
      super.includes(:subject, :topic)
    end
  end
end
