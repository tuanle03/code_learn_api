module API
  class Web::UsersAPI < Grape::API

    resource :users do

      desc 'Get a user',
        security: [access_token: {}]
      get do
        authenticate_user!
        status 200
        {
          success: true,
          user: {
            id: current_user.id,
            email: current_user.email,
            name: current_user.name,
            role: current_user.role,
            last_name: current_user.last_name,
            first_name: current_user.first_name,
            avatar_url: current_user.avatar_url,
            created_at: current_user.created_at.to_fs(:ymd_hms),
          },
          user_feedbacks: current_user.feedbacks.map do |feedback|
            {
              id: feedback.id,
              post_id: feedback.post_id,
              content: feedback.content,
              created_at: feedback.created_at.to_fs(:ymd_hms),
            }
          end,
          user_posts: current_user.posts.map do |post|
            {
              id: post.id,
              title: post.title,
              total_views: post.total_view,
              created_at: post.created_at.to_fs(:ymd_hms),
            }
          end,
          user_comments: current_user.comments.map do |comment|
            {
              id: comment.id,
              linked_object_id: comment.linked_object_id,
              linked_object_type: comment.linked_object_type,
              content: comment.content,
              created_at: comment.created_at.to_fs(:ymd_hms),
            }
          end,
          user_discussions: current_user.discussions.map do |discussion|
            {
              id: discussion.id,
              content: discussion.content,
              created_at: discussion.created_at.to_fs(:ymd_hms),
            }
          end
        }
      end

      desc 'Edit profile',
        security: [access_token: {}]
      params do
        optional :last_name, type: String, desc: 'Last name'
        optional :first_name, type: String, desc: 'First name'
        optional :avatar_url, type: String, desc: 'Avatar url'
        optional :old_password, type: String, desc: 'Old password'
        optional :new_password, type: String, desc: 'New password'
        optional :new_password_confirmation, type: String, desc: 'New password confirmation'
      end
      put do
        authenticate_user!
        if params[:old_password].present? && params[:new_password].present? && params[:new_password_confirmation].present?
          if params[:new_password] != params[:new_password_confirmation]
            error!({ success: false, message: 'Password confirmation does not match' }, 400)
          end
          unless current_user.valid_password?(params[:old_password])
            error!({ success: false, message: 'Old password is incorrect' }, 400)
          end
          current_user.password = params[:new_password]
          current_user.password_confirmation = params[:new_password_confirmation]
        end

        if params[:old_password].present? && params[:new_password].blank? && params[:new_password_confirmation].blank?
          error!({ success: false, message: 'New password is required' }, 400)
        end

        if params[:old_password].blank? && params[:new_password].present? && params[:new_password_confirmation].present?
          error!({ success: false, message: 'Old password is required' }, 400)
        end

        current_user.last_name = params[:last_name] if params[:last_name].present?
        current_user.first_name = params[:first_name] if params[:first_name].present?
        current_user.avatar_url = params[:avatar_url] if params[:avatar_url].present?

        if current_user.save
          status 200
          {
            success: true,
            message: 'Profile updated successfully',
          }
        else
          error!({ success: false, message: current_user.errors.full_messages.join(', ') }, 400)
        end
      end
    end
  end
end
