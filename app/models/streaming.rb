class Streaming < ApplicationRecord
  belongs_to :title
  belongs_to :service

  validates :url, presence: true
end
