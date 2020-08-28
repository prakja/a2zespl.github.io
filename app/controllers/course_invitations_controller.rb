class CourseInvitationsController < ApplicationController
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token

  def multiple_courses
    if not current_admin_user
      redirect_to "/admin/login"
      return
    end

    @courses_data = {}
    @current_admin_role = current_admin_user.role
    @courses = Course.public_courses
    @courses.each do |course|
      @courses_data[course.id] = [course.name]
    end
  end

  def createCourseInvitation
    begin
      @name = params[:name]
      @email = params[:email]
      @phone = params[:phone]
      @courseIds = params[:courseIds]
      @expiry = params[:expiry]

      @rowsArray = []

      @courseIds.each do |courseId|
        @row = {}
        @row["displayName"] = @name
        @row["email"] = @email
        @row["phone"] = @phone
        @row["role"] = 'courseStudent'
        @row["courseId"] = courseId.to_i
        @row["expiryAt"] = @expiry
        @row["skip_callback"] = true
        @rowsArray.push(@row)
      end

      p @rowsArray

      if(@courseIds.length() > 0)
        CourseInvitation.create!(@rowsArray)
      end

      respond_to do |format|
        format.html { render :new }
        format.json { render json: "Done", status: 200 }
      end

    rescue => exception
      render json: exception.to_s, status: 500
    end
  end

end
