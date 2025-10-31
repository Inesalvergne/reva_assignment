class NetPromoterScore < ApplicationRecord
  belongs_to :company, optional: true

  def self.global_nps
    where(company: nil)
  end
end
