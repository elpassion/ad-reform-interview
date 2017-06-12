class CreatePeople < ActiveRecord::Migration[5.1]
  def change
    create_table :people do |t|
      t.string :gender
      t.decimal :height, null: false, precision: 5, scale: 2
      t.decimal :weight, null: false, precision: 5, scale: 2

      t.timestamps
    end
  end
end
