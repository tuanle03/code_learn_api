# Ví dụ với 5 người dùng và 3 bài viết
5.times do |i|
  email = Faker::Internet.email
  password = Faker::Internet.password(min_length: 8)
  role = i.zero? ? 'admin' : 'user'
  first_name = Faker::Name.first_name
  last_name = Faker::Name.last_name
  avatar_url = Faker::Avatar.image

  user = User.create!(email: email, password: password, role: role, first_name: first_name, last_name: last_name, avatar_url: avatar_url)

  # Tạo 3 bài viết cho mỗi người dùng
  3.times do
    title = Faker::Lorem.sentence
    body = Faker::Lorem.paragraphs.join('\n')
    total_view = Faker::Number.between(from: 1, to: 100)
    status = ['approved'].sample

    post = Post.create!(title: title, body: body, user_id: user.id, total_view: total_view, status: status)

    # Tạo feedback
    Feedback.create!(content: Faker::Lorem.sentence, post_id: post.id, user_id: User.where.not(id: user.id).sample.id)

    # Tạo discussion
    discussion = Discussion.create!(content: Faker::Lorem.paragraph, user_id: User.where.not(id: user.id).sample.id, status: 'approved')

    # Tạo comment cho discussion
    Comment.create!(content: Faker::Lorem.sentence, user_id: user.id, linked_object_id: discussion.id, linked_object_type: 'Discussion', status: 'approved')
  end
end
