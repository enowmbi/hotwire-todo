class Task < ApplicationRecord
  validates :title, presence: true, length: { within: (10..100) }
end
