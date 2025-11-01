class Review < ApplicationRecord
  include PgSearch::Model
  pg_search_scope :search_by_description,
                  against: :description,
                  using: {
                    tsearch: { prefix: true }
                  }

  validates :company, :channel, :date, :rating, presence: true
  validates :rating, inclusion: { in: 1..5 }

  belongs_to :company

  delegate :name, to: :company, prefix: true

  enum :channel, {
    airbnb: 0,
    google: 1,
    internal: 2,
    vrbo: 3
  }, prefix: true

  scope :by_company, ->(company_name) {
    joins(:company).where(companies: { name: company_name })
  }

  scope :by_channels, ->(channels) {
    where(channel: channels)
  }

  scope :by_ratings, ->(ratings) {
    where(rating: ratings)
  }

  scope :by_date_range, ->(start_date, end_date) {
    scope = all
    scope = scope.where("date >= ?", start_date) if start_date.present?
    scope = scope.where("date <= ?", end_date) if end_date.present?
    scope
  }

  def display_date
    date.strftime("%d %b. %Y")
  end

  def display_rating
    "★" * rating + "☆" * (5 - rating)
  end
end
