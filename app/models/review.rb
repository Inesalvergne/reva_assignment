class Review < ApplicationRecord
  validates :company, :channel, :date, :rating, presence: true
  validates :rating, inclusion: { in: 1..5 }

  belongs_to :company

  enum :channel, {
    airbnb: 0,
    google: 1,
    booking: 2,
    internal: 3,
    vrbo: 4
  }, prefix: true
end
