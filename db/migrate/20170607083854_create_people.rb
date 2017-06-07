class CreatePeople < ActiveRecord::Migration[5.1]
  def change
    create_table :people do |t|
      t.string :gender
      t.integer :height, null: false
      t.integer :weight, null: false

      t.timestamps
    end
  end
end
