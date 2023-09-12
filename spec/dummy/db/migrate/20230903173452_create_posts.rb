# This migration comes from active_storage (originally 20170806125915)
class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |t|
      t.string :title
      t.integer :description
    end
  end
end
