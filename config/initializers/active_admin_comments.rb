module ActiveAdmin
  class Comment  < ActiveRecord::Base
    after_create :send_notification

    def send_notification
      p "In notification block"
      resource = nil
      if self.resource_type == "CustomerSupport"
        resource = CustomerSupport.find(self.resource_id)
      elsif self.resource_type == "CustomerIssue"
        resource = CustomerIssue.find(self.resource_id)
      else
        return
      end
      user_id = resource.userId
      user = User.find(user_id)
      comment_body = self.body
      p "Checking body and issue"
      if not resource.resolved? and comment_body.start_with?("Resolved:")
        resource.resolved = true
        resource.save
        message = comment_body.gsub("Resolved:", "").squish
        url = message.scan(/(?i)\b((?:[a-z][\w-]+:(?:\/{1,3}|[a-z0-9%])|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’]))/).first || nil
        if not url.nil?
          url = url.first
        end
        p url
        HTTParty.post(
          Rails.configuration.node_site_url + "api/v1/job/importantNewsNotification",
          body: {
            studentType: 'Selected',
            message: message,
            title: "Issue Resolved",
            imageUrl: nil,
            contextType: "LinkUrl",
            actionUrl: url || nil,
            courseId: nil,
            userId: user_id
        })
        HTTParty.post(
          Rails.configuration.node_site_url + "/api/v1/webhook/sendEmail",
          body: {
            to: user.email,
            subject: "Issue Resolved",
            message: message,
            altText: ""
        })
      else
        p "Passed, either format mis-match or issue is resolved!"
      end
    end
  end
end
