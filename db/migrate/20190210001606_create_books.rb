class CreateBooks < ActiveRecord::Migration[5.2]
  def change
    create_table :books do |t|
      t.string :title
      t.integer :pages
      t.integer :progress

      t.timestamps
    end
  end
end
