# Description: This file is used to create sample data for development environment

User.create!(email: 'mio@gmail.com', password: '12345678', role: 'admin', first_name: 'Mio', last_name: 'Admin', avatar_url: Faker::Avatar.image)

5.times do |i|
  email = Faker::Internet.email
  password = Faker::Internet.password(min_length: 8)
  role = i.zero? ? 'admin' : 'user'
  first_name = Faker::Name.first_name
  last_name = Faker::Name.last_name
  avatar_url = Faker::Avatar.image

  # Create user
  user = User.create!(email: email, password: password, role: role, first_name: first_name, last_name: last_name, avatar_url: avatar_url)

  # each user has 3 posts
  3.times do
    title = Faker::Lorem.sentence
    body = Faker::Lorem.paragraphs.join('\n')
    total_view = Faker::Number.between(from: 1, to: 100)
    status = ['approved'].sample

    # Create post
    post = Post.create!(title: title, body: body, user_id: user.id, total_view: total_view, status: status)

    # Create feedback
    Feedback.create!(content: Faker::Lorem.sentence, post_id: post.id, user_id: User.where.not(id: user.id).sample.id)

    # Create discussion
    discussion = Discussion.create!(content: Faker::Lorem.paragraph, user_id: User.where.not(id: user.id).sample.id, status: 'approved', title: Faker::Lorem.sentence)

    # Create comment
    Comment.create!(content: Faker::Lorem.sentence, user_id: user.id, linked_object_id: discussion.id, linked_object_type: 'Discussion', status: 'approved')
  end
end
