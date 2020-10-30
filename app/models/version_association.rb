class VersionAssociation < ApplicationRecord
  belongs_to :version, class_name: "versions", foreign_key: "version_id"
end