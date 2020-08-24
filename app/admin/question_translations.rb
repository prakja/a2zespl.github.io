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

  show do
    render partial: 'mathjax'
    attributes_table do
      row :id
      row :question do |object|
        raw(object.question)
      end
      row :explanation do |object|
        raw(object.explanation)
      end
      row :questionId do |object|
        raw('<a target="_blank" href="/admin/questions/' + object.questionId.to_s + '">' + "Question Link" + '</a>')
      end
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "Question Translation" do
      render partial: 'tinymce'
      render partial: 'mathjax'
      f.input "Question (English)", as: :fake, value: f.object.ques.nil? ? 'No question linked' : raw('<br />' + f.object.ques.question)
      f.input :question, input_html: { id: "question_question" }
      f.input "Explanation (English)", as: :fake, value: f.object.explanation.nil? ? 'No question linked' : raw('<br />' + f.object.ques.explanation)
      f.input :explanation, input_html: { id: "question_explanation" }
    end
    f.actions
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
