class CreateProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :products do |t|
      t.string :name
      t.string :price
      t.text :description
      t.string :country
      t.string :size
      t.string :brand
      t.string :condition
      t.string :style
      t.string :color
      t.text :image_urls, array: true, default: []

      t.timestamps
    end
  end
end
