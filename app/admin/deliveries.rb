ActiveAdmin.register Delivery do
  permit_params :deliveryType, :course, :courseValidity, :amount, :source, :purchasedAt, :name, :mobile, :address, :counselorName, :trackingNumber, :usb, :dongle, :packed, :delivered
  active_admin_import validate: true,
    headers_rewrites: { 'delivery type': :deliveryType, 'course': :course, 'course validity': :courseValidity, 'installment amount': :installmentAmount, 'source': :source, 'purchased at text': :purchasedAtText, 'name': :name, 'mobile': :mobile, 'address': :address, 'counselor name': :counselorName, 'tracking number': :trackingNumber, 'usb': :usb, 'dongle': :dongle, 'packed': :packed , 'delivered': :delivered, 'created at': :createdAt, 'updated at': :updatedAt},
    template_object: ActiveAdminImport::Model.new(
        hint: "file will be imported with such header format: 'delivery_type','course','course_validity'",
        csv_headers: ["delivery type","course","course validity","installment amount","source","purchased at text","name","mobile","address","counselor name","tracking number","usb","dongle","packed","delivered","created at","updated at"]
    )

  form do |f|
    f.inputs "Delivery" do
      f.input :deliveryType, as: :select, :collection => ["new", "renewal", "replacement", "installment"]
      f.input :course, as: :select, :collection => ["Full Course + Pendrive", "Physics Course + Pendrive", "Chemistry Course + Pendrive", "Biology Course + Pendrive", "Physics + Biology + Pendrive", "Chemistry + Biology + Pendrive", "Physics + Chemistry + Pendrive"]
      f.input :courseValidity, as: :date_picker, label: "Course Validity"
      f.input :amount, label: "Payment amount"
      f.input :source, label: "Source of Sale", as: :select, :collection => ["neetprep"]
      f.input :purchasedAt, as: :date_picker, label: "Course Purchased At"
      f.input :name, label: "Student name"
      f.input :mobile, label: "Student phone number"
      f.input :address, label: "Student address"
      f.input :counselorName, label: "Counselor name"
      f.input :trackingNumber, label: "Package tracking number"
      f.input :usb, as: :select, :collection => ["32 GB", "32 GB + 16 GB", "64 GB", "64 GB + 16 GB", "64 GB + 32 GB", "128 GB"]
      f.input :dongle, as: :select, :collection => ["1", "2", "3"]
      f.input :packed
      f.input :delivered
    end
    f.actions
  end

  member_action :history do
    @delivery = Delivery.find(params[:id])
    @versions = PaperTrail::Version.where(item_type: 'Delivery', item_id: @delivery.id)
    render "layouts/history"
  end

  index do
    id_column
    column (:deliveryType) { |delivery| raw(delivery.deliveryType) }
    column (:course) { |delivery| raw(delivery.course) }
    column (:courseValidity) { |delivery| raw(delivery.courseValidity)  }
    column (:amount) { |delivery| raw(delivery.amount)  }
    column (:installmentAmount) { |delivery| raw(delivery.installmentAmount)  }
    column (:source) { |delivery| raw(delivery.source)  }
    column (:purchasedAt) { |delivery| raw(delivery.purchasedAt)  }
    column (:purchasedAtText) { |delivery| raw(delivery.purchasedAtText)  }
    column (:name) { |delivery| raw(delivery.name)  }
    column (:mobile) { |delivery| raw(delivery.mobile)  }
    column (:address) { |delivery| raw(delivery.address)  }
    column (:counselorName) { |delivery| raw(delivery.counselorName)  }
    column (:trackingNumber) { |delivery| raw(delivery.trackingNumber)  }
    column (:usb) { |delivery| raw(delivery.usb)  }
    column (:dongle) { |delivery| raw(delivery.dongle)  }
    column (:packed) { |delivery| raw(delivery.packed)  }
    column (:delivered) { |delivery| raw(delivery.delivered)  }
    column ("History") {|delivery| raw('<a target="_blank" href="/admin/deliveries/' + (delivery.id).to_s + '/history">View History</a>')}
    actions
  end
end
