class CreateFollows < ActiveRecord::Migration[7.0]
  def change
    create_table :follows do |t|
      t.integer :following_user_id
      t.integer :followed_user_id
      t.boolean :status

      t.timestamps
    end
  end
end
