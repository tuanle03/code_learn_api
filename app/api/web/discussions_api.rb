module API
  class Web::DiscussionsAPI < Grape::API

    helpers do
      def format_discussion(discussion)
        {
          id: discussion.id,
          title: discussion.title,
          slug: discussion.slug,
          content: discussion.content,
          total_comments: discussion.total_comments,
          created_at: discussion.created_at.to_fs(:ymd_hms),
          user: {
            name: discussion.user.name,
            avatar_url: discussion.user.avatar_url
          }
        }
      end

      def format_comment(comment)
        {
          id: comment.id,
          content: comment.content,
          created_at: comment.created_at.to_fs(:ymd_hms),
          user: {
            name: comment.user.name,
            avatar_url: comment.user.avatar_url
          }
        }
      end
    end

    resource :discussions do

      desc 'Get list of discussions'
      params do
        optional :limit, type: Integer, default: 10, desc: 'Limit the number of discussions'
      end
      get do
        status 200
        {
          success: true,
          discussions: Discussion.approved.limit(params[:limit]).map { |discussion| format_discussion(discussion) }
        }
      end

      desc 'Get list of discussions by newest'
      params do
        optional :limit, type: Integer, default: 10, desc: 'Limit the number of discussions'
      end
      get '/newest' do
        discussions = Discussion.approved.newest.limit(params[:limit])
        status 200
        {
          success: true,
          discussions: discussions.map { |discussion| format_discussion(discussion) }
        }
      end

      desc 'Get list of discussions by most commented'
      params do
        optional :limit, type: Integer, default: 10, desc: 'Limit the number of discussions'
      end
      get '/most_commented' do
        discussions = Discussion.approved.most_commented.limit(params[:limit])
        status 200
        {
          success: true,
          discussions: discussions.map { |discussion| format_discussion(discussion) }
        }
      end

      desc 'Get a discussion'
      params do
        requires :id, type: String, desc: 'Discussion :id/:slug'
      end
      get ':id' do
        discussion = Discussion.friendly.find(params[:id])
        if discussion
          status 200
          {
            discussion: format_discussion(discussion)
          }
        else
          status 400
          {
            success: false,
            error: 'Discussion not found'
          }
        end
      end

      desc 'Create a discussion',
        security: [access_token: {}]
      params do
        requires :content, type: String, desc: 'Discussion content', allow_blank: false
        requires :title, type: String, desc: 'Discussion title', allow_blank: false
      end
      post do
        authenticate_user!
        discussion = current_user.discussions.new(content: params[:content], status: 'approved', title: params[:title])
        if discussion.save
          status 200
          {
            success: true,
            discussion: format_discussion(discussion)
          }
        else
          status 400
          {
            success: false,
            errors: discussion.errors.full_messages
          }
        end
      end

      desc 'Update a discussion',
        security: [access_token: {}]
      params do
        requires :id, type: String, desc: 'Discussion :id/:slug'
        requires :content, type: String, desc: 'Discussion content', allow_blank: false
      end
      put ':id' do
        authenticate_user!
        discussion = current_user.discussions.friendly.find(params[:id])
        if discussion.update(content: params[:content])
          status 200
          {
            success: true,
            message: 'Discussion updated successfully'
          }
        else
          status 400
          {
            success: false,
            errors: discussion.errors.full_messages
          }
        end
      end

      desc 'Reject a discussion',
        security: [access_token: {}]
      params do
        requires :id, type: String, desc: 'Discussion :id/:slug'
      end
      put ':id/reject' do
        authenticate_user!
        if current_user.admin?
          discussion = Discussion.friendly.find(params[:id])
        else
          discussion = current_user.discussions.friendly.find(params[:id])
        end
        if discussion.update(status: 'rejected')
          status 200
          {
            success: true,
            message: 'Discussion rejected successfully'
          }
        else
          status 400
          {
            success: false,
            errors: discussion.errors.full_messages
          }
        end
      end

      desc 'Delete a discussion',
        security: [access_token: {}]
      params do
        requires :id, type: String, desc: 'Discussion :id/:slug'
      end
      delete ':id' do
        authenticate_user!
        if current_user.admin?
          discussion = Discussion.friendly.find_by(id: params[:id]) || Discussion.friendly.find_by(slug: params[:id])
        else
          discussion = current_user.discussions.friendly.find_by(id: params[:id]) || current_user.discussions.friendly.find_by(slug: params[:id])
        end
        if discussion
          discussion.destroy
          status 200
          {
            success: true,
            message: 'Discussion deleted successfully'
          }
        else
          status 400
          {
            success: false,
            error: 'Discussion not found'
          }
        end
      end

      desc 'Get all comments of a discussion'
      params do
        requires :id, type: String, desc: 'Discussion :id/:slug'
      end
      get ':id/comments' do
        discussion = Discussion.approved.friendly.find(params[:id])
        if discussion
          status 200
          {
            success: true,
            comments: discussion.comments.approved.map { |comment| format_comment(comment) }
          }
        else
          status 400
          {
            success: false,
            error: 'Discussion not found'
          }
        end
      end

      desc 'Create a comment of a discussion',
        security: [access_token: {}]
      params do
        requires :id, type: String, desc: 'Discussion :id/:slug'
        requires :content, type: String, desc: 'Comment content', allow_blank: false
      end
      post ':id/comments' do
        authenticate_user!
        discussion = Discussion.approved.friendly.find(params[:id])
        if discussion
          comment = discussion.comments.new(user: current_user, content: params[:content], status: 'approved')
          if comment.save
            status 200
            {
              success: true,
              message: 'Comment created successfully',
            }
          else
            status 400
            {
              success: false,
              errors: comment.errors.full_messages
            }
          end
        else
          status 400
          {
            success: false,
            error: 'Discussion not found'
          }
        end
      end

      desc 'Update a comment of a discussion',
        security: [access_token: {}]
      params do
        requires :id, type: String, desc: 'Discussion :id/:slug'
        requires :comment_id, type: Integer, desc: 'Comment id'
        requires :content, type: String, desc: 'Comment content', allow_blank: false
      end
      put ':id/comments/:comment_id' do
        authenticate_user!
        discussion = Discussion.approved.friendly.find(params[:id])
        if discussion
          comment = discussion.comments.find_by(id: params[:comment_id])
          if comment.update(content: params[:content])
            status 200
            {
              success: true,
              message: 'Comment updated successfully',
            }
          else
            status 400
            {
              success: false,
              errors: comment.errors.full_messages
            }
          end
        else
          status 400
          {
            success: false,
            error: 'Discussion not found'
          }
        end
      end

      desc 'Reject a comment of a discussion',
        security: [access_token: {}]
      params do
        requires :id, type: String, desc: 'Discussion :id/:slug'
        requires :comment_id, type: Integer, desc: 'Comment id'
      end
      put ':id/comments/:comment_id/reject' do
        authenticate_user!
        discussion = Discussion.approved.friendly.find(params[:id])
        if discussion
          comment = discussion.comments.approved.find_by(id: params[:comment_id]).update(status: 'rejected')
          if comment
            status 200
            {
              success: true,
              message: 'Comment rejected successfully',
            }
          else
            status 400
            {
              success: false,
              errors: comment.errors.full_messages
            }
          end
        else
          status 400
          {
            success: false,
            error: 'Discussion not found'
          }
        end
      end

      desc 'Delete a comment of a discussion',
        security: [access_token: {}]
      params do
        requires :id, type: String, desc: 'Discussion :id/:slug'
        requires :comment_id, type: Integer, desc: 'Comment id'
      end
      delete ':id/comments/:comment_id' do
        authenticate_user!
        discussion = Discussion.approved.friendly.find(params[:id])
        if discussion
          comment = discussion.comments.find_by(id: params[:comment_id])
          if comment.destroy
            status 200
            {
              success: true,
              message: 'Comment deleted successfully',
            }
          else
            status 400
            {
              success: false,
              errors: comment.errors.full_messages
            }
          end
        else
          status 400
          {
            success: false,
            error: 'Discussion not found'
          }
        end
      end
    end
  end
end
