class DailyUserEvent < ApplicationRecord
  self.table_name = :DailyUserEvent

  scope :current_week, -> { where('"eventDate"::date between (date_trunc(\'week\', current_timestamp) at time zone \'Asia/Kolkata\')::date and (date_trunc(\'week\', current_timestamp) at time zone \'Asia/Kolkata\' + \'6 days\'::interval)::date')}
  scope :past_week, -> (past=4) {where('"eventDate"::date between (date_trunc(\'week\', current_timestamp) at time zone \'Asia/Kolkata\' - \'? weeks\'::interval)::date and (current_timestamp at time zone \'Asia/Kolkata\')::date', past)}

  # from past n weeks as specified to the end of current week
  scope :past_to_current_week, -> (past) {where('"eventDate"::date between (date_trunc(\'week\', current_timestamp) at time zone \'Asia/Kolkata\' - \'? weeks\'::interval)::date and (date_trunc(\'week\', current_timestamp) at time zone \'Asia/Kolkata\' + \'6 days\'::interval)::date', past)}

end
