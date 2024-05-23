class Service < ApplicationRecord
  has_many :streamings, dependent: :destroy
  # Although a title can have many streamings & services, the title ID is unique.
  # Specifying the distinct method will prevent the same title from being called
  # more than once when selecting titles with service or streaming joins
  has_many :titles, -> { distinct }, through: :streamings

  validates :name, presence: true
end
