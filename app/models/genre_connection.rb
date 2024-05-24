class GenreConnection < ApplicationRecord
  belongs_to :title, optional: true
  belongs_to :genre
  belongs_to :list, optional: true

  validate :either_title_or_list

  private

  def either_title_or_list
    if title_id.present? && list_id.present?
      errors.add(:base, 'Cannot link both a title and a list to a genre')
    elsif title_id.blank? && list_id.blank?
      errors.add(:base, 'Must link either a title or a list to a genre')
    end
  end
end
