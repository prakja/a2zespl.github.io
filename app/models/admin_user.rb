class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  scope :sales_team, -> {where(role: ['sales', 'sales2']).order('"id" ASC').pluck(:name).map{|name| [name].map(&:to_s).join(', ')}}
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  has_many :doubt_admins, class_name: "DoubtAdmin", foreign_key: "admin_user_id"
  has_many :doubts, through: :doubt_admins
  has_many :coachStudents, foreign_key: "coachId", class_name: 'StudentCoach'

  before_create :before_create_admin_user

  def self.distinct_faculty_name
    AdminUser.where(role: 'faculty').pluck("email")
  end

  def self.distinct_email_id
    AdminUser.pluck("email", "id")
  end

  def self.distinct_user_id
    AdminUser.pluck("email", "userId")
  end

  def before_create_admin_user
    if self.email.blank? or self.name.blank?
      return
    end

    @neetUser = User.where(email: self.email).first
    if @neetUser
      p "NEETprep user found"
      @neetUserProfile = UserProfile.where(userId: @neetUser.id).first
      @neetUserProfile.displayName = self.name
      @neetUserProfile.save
      self.userId = @neetUser.id
    else
      p "user not found"
    end

  end

end
