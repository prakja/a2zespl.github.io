Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  get "doubts/pending_stats"
  get "doubt_answers/answer"
  get "doubt_answers/connect_user"
  post "doubt_answers/post_answer"
  post "doubt_answers/toggle_good_flag"
  get "user_doubt_counts/stats"
  get "course_details/show"
  get "user_analytics/show"
  post "user_analytics/populate_user_activites"
  get "questions/pdf_questions"
  get "questions/add_explanation/:id", to: "questions#add_explanation"
  post "questions/update_explanation", to: "questions#update_explanation"
  get "questions/test_question_pdf/:id/", to: 'questions#test_question_pdf'
  get "videos/add_chapter_video/:videoId", to: "videos#add_chapter_video"
  post "videos/getSubjectsList"
  post "videos/getChaptersList"
  post "videos/createChapterVideo"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
