class CreateItems < ActiveRecord::Migration
  def change
    create_table   :items do |t|
      t.string     :name
      t.text       :description
      t.decimal    :cost
      t.belongs_to :wishlist, index: true
    end
  end
end
