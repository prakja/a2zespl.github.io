ActiveAdmin.register CourseInvitation do
  before_save do |course_invitation|
    course_invitation.admin_user = current_admin_user
  end
  permit_params :course, :displayName, :email, :phone, :role, :admin_user_id, :payments, :expiryAt, :courseId, :accepted, payment_ids: []
  remove_filter :payments, :versions, :courseInvitationPayments
  active_admin_import validate: true,
    timestamps: true,
    batch_size: 1,
    headers_rewrites: { 'name': :displayName,	'courseId': :courseId,	'email': :email,	'phone': :phone, 'expiryAt': :expiryAt, 'createdAt': :createdAt, 'updatedAt': :updatedAt },
    before_batch_import: ->(importer) {
      time = Time.now
      importer.csv_lines.each do |line|
        importer.options['time'] = time
        expire_at = line[4]
        line.delete_at(4)
        line.insert(-1, DateTime.parse(expire_at).midnight)
        line.insert(-1, time) 
        line.insert(-1, time)
      end
    },
    after_batch_import: lambda { |importer|
      time = importer.options['time']
      course_invitation = CourseInvitation.where(createdAt: time).first
      hubspot_url = 'https://api.hubapi.com/contacts/v1/contact/createOrUpdate/email/' + course_invitation.email + '/?hapikey=' + Rails.application.config.hubspot_key
      hubspot_req = HTTParty.post(hubspot_url, :headers => { 'Content-Type' => 'application/json' }, body: {
        'properties' => [
          {
            'property' => 'hubspot_owner_id',
            'value' => 42184047
          }
        ]}.to_json)
        p hubspot_req.parsed_response
    },
    template_object: ActiveAdminImport::Model.new(
        hint: "File will be imported with such header format: 'name',	'courseId',	'email',	'phone',  'expiryAt'",
        csv_headers: ['name',	'courseId',	'email',	'phone',  'expiryAt', 'createdAt', 'updatedAt']
    )

  member_action :resendinvite, :method=>:get do
    p resource
    redirect_to resource_path
  end

  controller do
    def resendinvite
      p resource
      resource.update(updatedAt: Time.now)
      redirect_to resource_path
    end
  end

  action_item :send_multiple_course_invitations, only: :index do
    link_to 'Send Multiple Course Invitations', '../../course_invitations/multiple_courses'
  end

  action_item :resend_course_invitation, only: :show do
    link_to 'Resend Course Invite', resource.id.to_s + '/resendinvite'
  end

  scope "invitations without payments", show_count: false, if: -> { current_admin_user.role == 'admin' or current_admin_user.role == 'accounts' } do |courseInvitation|
    courseInvitation.invitations_without_payment
  end

  #scope "invitations expiring tomorrow", if: -> { current_admin_user.role == 'admin' or current_admin_user.role == 'accounts' } do |courseInvitation|
  #  courseInvitation.invitations_expiring_by_tomorrow
  #end

  #scope "my invitations expiring in 7 days" do |courseInvitation|
  #  courseInvitation.my_invitations_expiring_soon(current_admin_user.id.to_s)
  #end

  #scope "my invitations expiring tomorrow" do |courseInvitation|
  #  courseInvitation.my_invitations_expiring_by_tomorrow(current_admin_user.id.to_s)
  #end

  scope :invitation_created_more_than_7days_by_sales, show_count: false
  scope :dronstudy_leads, show_count: false

  member_action :history do
    @courseinvitation = CourseInvitation.find(params[:id])
    @versions = PaperTrail::Version.where(item_type: 'CourseInvitation', item_id: @courseinvitation.id)
    render "layouts/history"
  end

  controller do
    def scoped_collection
      super.includes :course, :payments
    end
  end

  csv do
    column (:course) { |courseInvitation| raw(courseInvitation.course.name)  }
    column (:displayName) { |courseInvitation| raw(courseInvitation.displayName)  }
    column (:email) { |courseInvitation| raw(courseInvitation.email)  }
    column (:phone) { |courseInvitation| raw(courseInvitation.phone)  }
    column "Amount" do |courseInvitation|
     courseInvitation.payments.map { |payment| payment.amount.to_int }.compact
    end
    column :expiryAt
    column :createdAt
  end

  index do
    id_column
    column :course
    column (:displayName) { |courseInvitation| raw(courseInvitation.displayName)  }
    column (:email) { |courseInvitation| raw(courseInvitation.email)  }
    column (:phone) { |courseInvitation| raw(courseInvitation.phone)  }
    # column (:role) { |courseInvitation| raw(courseInvitation.role)  }
    # column :payments
    # column "Amount" do |courseInvitation|
    #  courseInvitation.payments.map { |payment| payment.amount }.compact
    # end
    column :expiryAt
    column :createdAt
    column ("Admin User") { |courseInvitation|  courseInvitation.admin_user_id != nil ? raw(AdminUser.find(courseInvitation.admin_user_id).email) : ""}
    column ("History") {|courseInvitation| raw('<a target="_blank" href="/admin/course_invitations/' + (courseInvitation.id).to_s + '/history">View History</a>')}
    actions
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "CourseInvitation" do
      f.input :course, include_hidden: false, input_html: { class: "select2" }, :collection => Course.public_courses, hint: "Search course by name or select from list"  if f.object.new_record?
      f.input :course, include_hidden: false, input_html: { class: "select2", readonly: true, disabled: true }, :collection => Course.public_courses, hint: "Can not change Course from here, set *Expire Course At* to a *past date* from below to expire course invitation and create a new invitation to give course access on different course" unless f.object.new_record?
      f.input :displayName, label: "Name"
      f.input :email, label: "Email"
      f.input :phone, label: "Phone" if f.object.new_record?
      f.input :phone, label: "Phone", hint: "If course invitation is not getting accepted, then this phone number might already be linked to another email already. Please add a different student's number if possible." unless f.object.new_record?
      f.input :role, as: :hidden, :input_html => { :value => "courseStudent"}
      # f.input :payments, include_hidden: false, multiple: true, input_html: { class: "select2" }, :collection => Payment.all_payments_3_months
      f.input :expiryAt, as: :date_picker, label: "Expire Course At"
      f.input :admin_user_id, as: :hidden, :input_html => { :value => current_admin_user.id }
    end
    f.actions
  end

end
