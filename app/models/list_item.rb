class ListItem < ApplicationRecord
  belongs_to :title
  belongs_to :list
end
