class CreateProductDetails < ActiveRecord::Migration[7.2]
  def change
    create_table :product_details do |t|
      t.string :title
      t.text :description
      t.float :price
      t.string :product_image

      t.timestamps
    end
  end
end
