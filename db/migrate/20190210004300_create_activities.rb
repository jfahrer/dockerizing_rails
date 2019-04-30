class CreateActivities < ActiveRecord::Migration[5.2]
  def change
    create_table :activities do |t|
      t.references :book, foreign_key: true
      t.integer :pages_read

      t.timestamps
    end
  end
end
