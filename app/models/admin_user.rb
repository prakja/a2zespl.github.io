class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  scope :sales_team, -> {where(role: 'sales').order('"id" ASC').pluck(:name).map{|name| [name].map(&:to_s).join(', ')}}
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable
  
  has_many :doubt_admins, class_name: "DoubtAdmin", foreign_key: "admin_user_id"
  has_many :doubts, through: :doubt_admins

  def self.distinct_faculty_name
    AdminUser.where(role: 'faculty').pluck("email")
  end

  def self.distinct_faculty_email_id
    AdminUser.where(role: 'faculty').pluck("email", "id")
  end
end
