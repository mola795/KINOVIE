class ListItem < ApplicationRecord
  belongs_to :title
  belongs_to :list

  validates :title_id, presence: true
  # validates :rank, presence: true
end
