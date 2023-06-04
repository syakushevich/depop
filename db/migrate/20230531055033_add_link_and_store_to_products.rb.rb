class AddLinkAndStoreToProducts < ActiveRecord::Migration[6.1]
  def change
    add_column :products, :link, :string
    add_column :products, :store, :integer
  end
end
