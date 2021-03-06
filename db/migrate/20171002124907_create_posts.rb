class CreatePosts < ActiveRecord::Migration[5.1]
  def change
    create_table :posts do |t|
      t.references :player
      t.references :room, null: false
      t.text :content, null: false
      t.integer :day, null: false
      t.integer :owner, default: 0, null: false

      t.timestamps
    end
  end
end
