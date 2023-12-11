class CreateDiscussions < ActiveRecord::Migration[7.0]
  def change
    create_table :discussions do |t|
      t.integer :user_id
      t.string :content
      t.string :status

      t.timestamps
    end
  end
end
