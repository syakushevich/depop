class Product < ApplicationRecord
  def self.from_last_day
    where('created_at >= ?', 24.hours.ago)
  end
end
