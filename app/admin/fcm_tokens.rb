ActiveAdmin.register FcmToken do

batch_action :notify, form: {
  title: :text,
  message: :textarea,
  type: ["", "ExternalWebsite", "InternalWebsite"],
  redirectUrl: :text,
  imageUrl: :text,
  sendTo: ["Selected", "AllPaid", "AllNonPaid", "AllUsers"]
  
} do |ids, inputs|
  userId = nil

  if inputs['sendTo'] == 'Selected'
    userId = FcmToken.find(ids[0]).userId
  end

  title = inputs['title']
  message = inputs['message']
  redirect = inputs['redirectUrl']
  type = inputs['type']
  imgUrl = inputs['imageUrl']

  HTTParty.post(
    # Rails.configuration.node_site_url + "api/v1/job/importantNewsNotification",
    "http://192.168.1.25:3001/api/v1/job/importantNewsNotification",
    body: {
      title: title,
      message: message,
      actionUrl: redirect,
      contextType: type,
      imageUrl: imgUrl,
      studentType: inputs['sendTo'],
      userId: userId
    }
  )

  # FcmToken.sent_notification(title, message, redirect, fcmTokens)

  # redirect_to collection_path, notice: [ids, inputs].to_s
end

end
