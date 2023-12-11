class CreateFeedbacks < ActiveRecord::Migration[7.0]
  def change
    create_table :feedbacks do |t|
      t.integer :user_id
      t.integer :post_id
      t.string :content

      t.timestamps
    end
  end
end
