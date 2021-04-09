ActiveAdmin.register Delivery do
  permit_params :deliveryType, :course, :description, :courseValidity, :amount, :source, :purchasedAt, :dueAmount, :dueDate, :name, :email, :mobile, :address, :counselorName, :courierSource, :status, :trackingNumber, :usb, :dongle, :packed, :delivered
  remove_filter :versions
  active_admin_import validate: true,
    headers_rewrites: { 'delivery type': :deliveryType, 'course': :course, 'course validity': :courseValidity, 'installment amount': :installmentAmount, 'source': :source, 'purchased at text': :purchasedAtText, 'name': :name, 'mobile': :mobile, 'address': :address, 'counselor name': :counselorName, 'tracking number': :trackingNumber, 'usb': :usb, 'dongle': :dongle, 'packed': :packed , 'delivered': :delivered, 'created at': :createdAt, 'updated at': :updatedAt},
    template_object: ActiveAdminImport::Model.new(
        hint: "File will be imported with such header format: 'delivery_type','course','course_validity'",
        csv_headers: ["delivery type","course","course validity","installment amount","source","purchased at text","name","mobile","address","counselor name","tracking number","usb","dongle","packed","delivered","created at","updated at"]
    )

  filter :id_eq, as: :number, label: "Delivery ID"
  preserve_default_filters!

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "Delivery" do
      f.input :deliveryType, as: :select, :collection => ["new", "renewal", "replacement", "installment"]
      f.input :course, as: :select, :collection => ["Full Course + Pendrive", "Physics Course + Pendrive", "Chemistry Course + Pendrive", "Biology Course + Pendrive", "Physics + Biology + Pendrive", "Chemistry + Biology + Pendrive", "Physics + Chemistry + Pendrive", "NEET Short Duration Course + Pendrive", "Dongle Only", "9th Class Course + Pendrive", "10th Class Course + Pendrive", "11th Class Course + Pendrive", "12th Class Course + Pendrive", "NEET Physics Video Module - Mechanics", "NEET Physics Video Module - Properties of Bulk Matter & Heat", "NEET Physics Video Module - Electrodynamics & Magnetism", "NEET Physics Video Module - Optics & Modern Physics", "NEET Chemistry Video Module - Physical Chemistry", "NEET Chemistry Video Module - Inorganic Chemistry", "NEET Chemistry Video Module - Organic Chemistry", "NEET Biology Video Module - Human Physiology", "NEET Biology Video Module - Plant Physiology", "NEET Biology Video Module - Diversity", "NEET Biology Video Module - Genetics", "NEET Biology Video Module - Biotechnolology & Ecology"]
      f.input :source, label: "Source of Sale", as: :select, :collection => ["neetprep"]
      f.input :description, hint: "Useful information about delivery, Example: send 64 GB pendrive only, send dongle only...etc"
      f.input :courseValidity, as: :date_picker, label: "Course Validity"
      f.input :purchasedAt, as: :date_picker, label: "Course Purchased At"
      f.input :amount, label: "Payment amount"
      f.input :dueAmount, label: "Due amount in case of installment"
      f.input :dueDate, as: :date_picker, label: "Due date in case of installment", hint: "Date on which student will pay the due amount"
      f.input :name, label: "Student name"
      f.input :email, label: "Student email"
      f.input :mobile, label: "Student phone number"
      f.input :address, label: "Student address"
      f.input :counselorName, label: "Counselor name"
      f.input :courierSource, label: "Courier source", as: :select, :collection => ["office collect", "DTDC", "speed post", "DTDC + party collect", "speed post + party collect"]
      f.input :status, label: "Delivery status", hint: "Example: Done, No courier service, Wrong adrress...etc"
      f.input :trackingNumber, label: "Package tracking number"
      f.input :usb, as: :select, :collection => ["32 GB", "32 GB + 16 GB", "64 GB", "64 GB + 16 GB", "64 GB + 32 GB", "64 GB + 64 GB" , "128 GB"]
      f.input :dongle, as: :select, :collection => ["1"], selected: '1'
      if current_admin_user.role == 'admin' or current_admin_user.role == 'support'
        f.input :packed
        f.input :delivered
      else
        f.input :packed, input_html: { disabled: true }
        f.input :delivered, input_html: { disabled: true }
      end
    end
    f.actions
  end

  member_action :history do
    @delivery = Delivery.find(params[:id])
    @versions = PaperTrail::Version.where(item_type: 'Delivery', item_id: @delivery.id)
    render "layouts/history"
  end

  show do |f|
    attributes_table do
      row :id
      row "Tracking Status" do |delivery|
        if delivery.trackingNumber and delivery.trackingNumber.length == 9
          if delivery.check_tracking(delivery.trackingNumber)
            JSON.parse(delivery.check_tracking(delivery.trackingNumber))[0]["deliveryStatus"] + ' on ' + JSON.parse(delivery.check_tracking(delivery.trackingNumber))[0]["dateWithNoSuffix"]
          end
        end
      end
    end
  end

  index do
    id_column
    if current_admin_user.role == 'admin' or current_admin_user.role == 'support'
      column "Possible Duplicate" do |delivery|
        delivery.check_duplicate(delivery.email, delivery.mobile, delivery.createdAt)
      end
    end
    column (:deliveryType) { |delivery| raw(delivery.deliveryType) }
    column (:course) { |delivery| raw(delivery.course) }
    column :description
    column :courseValidity
    column (:amount) { |delivery| raw(delivery.amount)  }
    column (:source) { |delivery| raw(delivery.source)  }
    column :purchasedAt
    column (:dueAmount) { |delivery| raw(delivery.dueAmount)  }
    column :dueDate
    column (:name) { |delivery| raw(delivery.name)  }
    column (:email) { |delivery| raw(delivery.email)  }
    column (:mobile) { |delivery| raw(delivery.mobile)  }
    column (:address) { |delivery| raw(delivery.address)  }
    column (:counselorName) { |delivery| raw(delivery.counselorName)  }
    column (:courierSource) { |delivery| raw(delivery.courierSource)  }
    column (:status) { |delivery| raw(delivery.status)  }
    column (:trackingNumber) { |delivery| raw(delivery.trackingNumber)  }
    column (:usb) { |delivery| raw(delivery.usb)  }
    column (:dongle) { |delivery| raw(delivery.dongle)  }
    if current_admin_user.role == 'admin' or current_admin_user.role == 'support'
      toggle_bool_column :packed
      toggle_bool_column :delivered
    else
      column :packed
      column :delivered
    end
    column :createdAt
    column ("History") {|delivery| raw('<a target="_blank" href="/admin/deliveries/' + (delivery.id).to_s + '/history">View History</a>')}
    actions
  end
end
