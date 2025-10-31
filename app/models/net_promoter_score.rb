class NetPromoterScore < ApplicationRecord
  include NetPromoterScoreStatistics

  belongs_to :company, optional: true

  def self.global_nps
    where(company: nil).take
  end
end
