class CreatePaymentConversionTracking < ActiveRecord::Migration[5.2]
  def change
    create_table ("public.PaymentConversion") do |t|
      t.string :utm_campaign
      t.string :utm_source
      t.string :utm_medium
      t.string :campaignid
      t.string :adgroupid
      t.string :keyword
      t.string :matchtype
      t.string :creative
      t.string :placement
      t.string :target
      t.string :gclid
      t.integer :paymentId, null: false
      t.datetime :createdAt, null: false
      t.datetime :updatedAt, null: false
    end
    add_foreign_key "PaymentConversion", "Payment", column: :paymentId, primary_key: "id"
  end
end
