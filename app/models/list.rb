class List < ApplicationRecord
  belongs_to :user
  has_many :list_items

  # before_validation :set_defaults
  validates :name, presence: true

  # private

  # def set_defaults
  #   status = "Private" if status.blank?
  # end
end
