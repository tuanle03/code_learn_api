class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :linked_object, polymorphic: true
end
