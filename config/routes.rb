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
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
