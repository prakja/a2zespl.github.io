class WorkLog < ApplicationRecord
    include ActiveModel::Validations

    has_paper_trail
    attr_readonly :date

    validates_presence_of :start_time, :end_time, :content, :total_hours
    validates :date, uniqueness: { scope: :admin_user_id, message: 'You have already submitted Work log for today' }, on: :create

    scope :my_logs, -> (current_admin_user) {self.where(:admin_user_id => current_admin_user.id)}
    belongs_to :created_by, class_name: :AdminUser, foreign_key: :admin_user_id
end
