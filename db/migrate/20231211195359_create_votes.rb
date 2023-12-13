class CreateVotes < ActiveRecord::Migration[7.0]
  def change
    create_table :votes do |t|
      t.integer :user_id
      t.integer :linked_object_id
      t.string :linked_object_type
      t.boolean :status

      t.timestamps
    end
  end
end
