class AddTitleToDiscussions < ActiveRecord::Migration[7.0]
  def change
    add_column :discussions, :title, :string
  end
end
