Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  get "doubts/index"
  get "doubts/edit"
  get "doubts/show"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
