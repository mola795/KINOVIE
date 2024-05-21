class GenreConnection < ApplicationRecord
  belongs_to :title
  belongs_to :genre
end
