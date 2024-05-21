class Person < ApplicationRecord
  has_many :people_titles
  has_many :titles, through: :people_titles

  validates :name, presence: true
end
