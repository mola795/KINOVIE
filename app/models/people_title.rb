class PeopleTitle < ApplicationRecord
  belongs_to :title
  belongs_to :person
end
