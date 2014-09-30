class CreateWishlists < ActiveRecord::Migration
  def change
    create_table   :wishlists do |t|
      t.string     :title
      t.text       :description
      t.decimal    :total_cost
      t.belongs_to :user, index: true
    end
  end
end
