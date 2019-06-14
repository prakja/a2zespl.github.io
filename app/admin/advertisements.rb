require 'aws-sdk'

ActiveAdmin.register Advertisement do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end
permit_params :mobile_URL_Image, :web_URL_Image, :webUrl, :mobileUrl, :startedAt, :expiryAt, :link, :id, :backgroundColor
form do |f|
  f.inputs "Details" do
    f.input :web_URL_Image, :as => :file, input_html: { accept: ".jpeg, .png" }
    f.input :mobile_URL_Image, :as => :file, input_html: { accept: ".jpeg, .png" }
    # f.input :webUrl do
    #   image_tag(f.webUrl)
    # end
    # f.input :mobileUrl do
    #   image_tag(f.mobileUrl)
    # end
    f.input :startedAt, as: :datepicker
    f.input :expiryAt, as: :datepicker
    f.input :link
    f.input :backgroundColor
  end
  f.actions
end

show do |f|
  attributes_table do
    row :id
    row :webUrl do
      image_tag(f.webUrl)
    end
    row :mobileUrl do
      image_tag(f.mobileUrl)
    end
    row :startedAt
    row :expiryAt
    row :link
    row :backgroundColor
  end
end

# https://docs.aws.amazon.com/sdk-for-ruby/v3/api/index.html
controller do

  def save_to_s3(file)
    Aws.config.update({
      region: 'us-west-2',
      credentials: Aws::Credentials.new('AKIAYEPQTPG6K7CEFU6D', 'XtUqnXWkwvPvlK+t8gwuShuESJA1fjnBV1q6AwTX')
    })
    s3 = Aws::S3::Resource.new
    bucket = s3.bucket('neetprep-from-ruby')
    obj = bucket.object('key_' + Time.now.to_s + file.original_filename + '.jpeg')
    File.open(file.tempfile.path, 'rb') do |file|
      obj.put(acl: "public-read", body: file)
    end
    # replace s3 url with cdn url
    return obj.public_url.gsub('neetprep-from-ruby.s3.us-west-2.amazonaws.com', 'neetprepr.b-cdn.net')
  end    

  def create()
    advertisement = permitted_params[:advertisement]
    web_URL_Image = advertisement[:web_URL_Image]
    mobile_URL_Image = advertisement[:mobile_URL_Image]
    startedAt = advertisement[:startedAt]
    expiryAt = advertisement[:expiryAt]
    link = advertisement[:link]
    backgroundColor = advertisement[:backgroundColor]

    @advertisement = Advertisement.new()
    @advertisement[:webUrl] = save_to_s3(web_URL_Image)
    @advertisement[:mobileUrl] = save_to_s3(mobile_URL_Image)
    @advertisement[:startedAt] = Date.parse(startedAt).to_time
    @advertisement[:expiryAt] = Date.parse(expiryAt).to_time
    @advertisement[:link] = link
    @advertisement[:createdAt] = Time.now
    @advertisement[:updatedAt] = Time.now
    @advertisement[:backgroundColor] = backgroundColor

    if not backgroundColor.start_with?('#')
      flash.now[:error] = "Color should start with '#'"
      render :new
      return
    end

    if @advertisement.save
      redirect_to admin_advertisement_path(@advertisement)
    else
      render :new
    end
  end

  def update()
    advertisement_params = permitted_params[:advertisement]
    id = permitted_params[:id]
    web_URL_Image = advertisement_params[:web_URL_Image]
    mobile_URL_Image = advertisement_params[:mobile_URL_Image]
    startedAt = advertisement_params[:startedAt]
    expiryAt = advertisement_params[:expiryAt]
    link = advertisement_params[:link]
    backgroundColor = advertisement_params[:backgroundColor]

    @advertisement = Advertisement.find_by(id: id)

    if web_URL_Image != nil
      @advertisement[:webUrl] = save_to_s3(web_URL_Image)
    end

    if mobile_URL_Image != nil
      @advertisement[:mobileUrl] = save_to_s3(mobile_URL_Image)
    end

    @advertisement[:startedAt] = Date.parse(startedAt).to_time
    @advertisement[:expiryAt] = Date.parse(expiryAt).to_time
    @advertisement[:link] = link
    @advertisement[:updatedAt] = Time.now
    @advertisement[:backgroundColor] = backgroundColor
    if not backgroundColor.start_with?('#')
      flash.now[:error] = "Color should start with '#'"
      render :new
      return
    end
    
    if @advertisement.save
      redirect_to admin_advertisement_path(@advertisement)
    else
      render :new
    end
  end

end

end
