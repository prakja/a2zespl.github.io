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
  get "tests/add_chapter_test/:testId", to: "tests#add_chapter_test"
  post "tests/getSubjectsList"
  post "tests/getChaptersList"
  post "tests/createChapterTest"
  get "course_details/booster"
  get "payments/generate_url", to: "payments#generate_url"
  get "matviews/forced_update"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get "/livesession/:id/", to: "group_chats#group"
  get "/teacher/livesession/:id", to: "group_chats#teacher_view"

  post "/livesession/create_chat", to: "group_chats#create_chat"
  post "/livesession/block_user", to: "group_chats#block_user"
  post "/livesession/delete_message", to: "group_chats#delete_message"
  post "/livesession/end_chat", to: "group_chats#end_chat"
  post "/livesession/send_question", to: "group_chats#send_question"
  post "/livesession/check_question", to: "group_chats#check_question"
  post "/livesession/show_analytics", to: "group_chats#show_analytics"
end

