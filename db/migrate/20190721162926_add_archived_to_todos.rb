class AddArchivedToTodos < ActiveRecord::Migration[5.2]
  def change
    add_column :todos, :archived_at, :datetime
  end
end
