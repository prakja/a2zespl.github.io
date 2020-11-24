class Constant < ApplicationRecord
  self.table_name = "Constant"

  before_create :set_value
  before_update :set_value

  def set_value
    if self.value.blank?
      self.value = nil
    else
      self.value = JSON.parse(self.value)
    end
  end
end