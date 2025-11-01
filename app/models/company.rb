class Company < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  has_many :reviews, dependent: :destroy
  has_many :net_promoter_scores, dependent: :destroy
end
