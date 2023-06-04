class Product < ApplicationRecord
  enum store: { depop: 1, ebay: 2 }

  def self.from_last_day
    where('created_at >= ?', 24.hours.ago)
  end
end
