module AP
  class Web::PostsAPI < Grape::API

    helpers do
      def format_post(post)
        {
          id: post.id,
          title: post.title,
          body: post.body,
          total_view: post.total_view,
          total_feedback: post.feedbacks.count,
          created_at: post.created_at.to_fs(:ymd_hms)
        }
      end
    end

    resource :posts do

      desc 'Get a list of posts by limit'
      params do
        optional :limit, type: Integer, default: 10, desc: 'Limit number of posts'
      end
      get do
        posts = Post.approved.limit(params[:limit]).map { |post| format_post(post) }
        status 200
        {
          success: true,
          posts: posts
        }
      end

      desc 'Get a list of posts by newest'
      params do
        optional :limit, type: Integer, default: 10, desc: 'Limit number of posts'
      end
      get '/newest' do
        posts = Post.approved.newest.limit(params[:limit]).map { |post| format_post(post) }
        status 200
        {
          success: true,
          posts: posts
        }
      end

      desc 'Get a list of posts by most viewed'
      params do
        optional :limit, type: Integer, default: 10, desc: 'Limit number of posts'
      end
      get '/most_viewed' do
        posts = Post.approved.most_viewed.limit(params[:limit]).map { |post| format_post(post) }
        status 200
        {
          success: true,
          posts: posts
        }
      end

      desc 'Get a post'
      params do
        requires :id, type: Integer, desc: 'Post id'
      end
      get ':id' do
        post = Post.find_by(id: params[:id])
        if post
          post.update(total_view: post.total_view + 1)
          status 200
          {
            success: true,
            post: format_post(post)
          }
        else
          status 400
          {
            success: false,
            error: 'Post not found'
          }
        end
      end

      desc 'Create a post'
      params do
        requires :title, type: String, desc: 'Post title', allow_blank: false
        requires :body, type: String, desc: 'Post body', allow_blank: false
      end
      post do
        authenticate_user!
        if current_user.admin?
          post = current_user.posts.new({
            title: params[:title],
            body: params[:body],
            status: 'approved'
          })
        end

        if post.save
          status 200
          {
            success: true,
            message: 'Post created successfully'
          }
        else
          status 400
          {
            success: false,
            error: 'Post cannot be created'
          }
        end
      end

      desc 'Update a post'
      params do
        requires :id, type: Integer, desc: 'Post id'
        optional :new_title, type: String, desc: 'New post title'
        optional :new_body, type: String, desc: 'New post body'
      end
      put ':id' do
        authenticate_user!
        post = current_user.posts.find_by(id: params[:id])
        if post
          post.update({
            title: params[:new_title],
            body: params[:new_body]
          })
          status 200
          {
            success: true,
            message: 'Post updated successfully'
          }
        else
          status 400
          {
            success: false,
            error: 'Post cannot be updated'
          }
        end
      end

      desc 'Delete a post'
      params do
        requires :id, type: Integer, desc: 'Post id'
      end
      delete ':id' do
        authenticate_user!
        if current_user.admin?
          post = Post.find_by(id: params[:id])
        else
          post = current_user.posts.find_by(id: params[:id])
        end

        if post
          post.update(status: 'deleted')
          status 200
          {
            success: true,
            message: 'Post deleted successfully'
          }
        else
          status 400
          {
            success: false,
            error: 'Post cannot be deleted'
          }
        end
      end

      desc 'List of posts by user'
      params do
        requires :id, type: Integer, desc: 'User id'
      end
      get '/user/:id' do
        status 200
        {
          success: true,
          posts: current_user.posts.approved.map { |post| format_post(post) }
        }
      end

      desc 'Approve a post'
      params do
        requires :id, type: Integer, desc: 'Post id'
      end
      put '/approve/:id' do
        authenticate_user!
        if current_user.admin?
          post = Post.find_by(id: params[:id])
          if post
            post.update(status: 'approved')
            status 200
            {
              success: true,
              message: 'Post approved successfully'
            }
          end
        else
          status 400
          {
            success: false,
            error: 'You are not authorized'
          }
        end
      end

      desc 'Get a list feedbacks of a post'
      params do
        requires :id, type: Integer, desc: 'Post id'
      end
      get '/:id/feedbacks' do
        feedbacks = Post.find_by(id: params[:id])&.feedbacks
        return status 400 unless feedbacks
        status 200
        {
          success: true,
          feedbacks: feedbacks.map do |feedback|
            {
              id: feedback.id,
              user_name: feedback.user.name,
              content: feedback.content,
              total_like: feedback.total_likes,
              created_at: feedback.created_at.to_fs(:ymd_hms)
            }
          end
        }
      end
    end
  end
end
