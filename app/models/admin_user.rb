class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  scope :sales_team, -> {where(role: 'sales').order('"id" ASC').pluck(:name).map{|name| [name].map(&:to_s).join(', ')}}
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable
end
