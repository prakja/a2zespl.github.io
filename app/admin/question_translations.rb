ActiveAdmin.register QuestionTranslation do
  remove_filter :ques 

  index do
    selectable_column
    id_column
    column ("Question") { |qe|
      auto_link(qe.ques)
    }
    column ("Question") { |qe|
      raw(qe.question)
    }
    column ("Explanation") {|qe|
      raw(qe.explanation)
    }
    actions
  end

  controller do
    def scoped_collection
      super.includes(:ques)
    end
  end

  csv do
    column :id
    column :question
    column :explanation
  end

end
