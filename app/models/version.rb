class Version < ApplicationRecord
  has_many :version_associations, class_name: "version_associations", foreign_key: "version_id"
end