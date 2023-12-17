module API
  class Web::FeedbacksAPI < Grape::API
    resource :feedbacks do
      desc 'Create feedback'
      params do
        requires :content, type: String, allow_blank: false
        requires :post_id, type: Integer
      end
      post do
        authenticate_user!
        feedback = current_user.feedbacks.new(content: params[:content], post_id: params[:post_id])
        if feedback.save
          status 200
          {
            success: true,
            message: 'Feedback created'
          }
        else
          status 400
          {
            success: false,
            message: feedback.error.full_messages
          }
        end
      end

      desc 'detail of feedback'
      params do
        requires :id, type: Integer
      end
      get ':id' do
        feedback = Feedback.find_by(id: params[:id])
        if feedback
          status 200
          {
            success: true,
            feedback: feedback
          }
        else
          status 400
          {
            success: false,
            message: 'Feedback not found'
          }
        end
      end

      desc 'Delete feedback'
      params do
        requires :id, type: Integer
      end
      delete ':id' do
        authenticate_user!
        feedback = current_user.feedbacks.find_by(id: params[:id])
        return status 400 if feedback.blank?
        if feedback.destroy
          status 200
          {
            success: true,
            message: 'Feedback deleted'
          }
        else
          status 400
          {
            success: false,
            message: 'Feedback not found'
          }
        end
      end

      desc 'Update feedback'
      params do
        requires :id, type: Integer
        requires :new_content, type: String, allow_blank: false
      end
      put ':id' do
        authenticate_user!
        feedback = current_user.feedbacks.find_by(id: params[:id])
        feedback.update(content: params[:new_content])
        if feedback.save
          status 200
          {
            success: true,
            message: 'Feedback updated'
          }
        else
          status 400
          {
            success: false,
            message: 'Feedback can not update'
          }
        end
      end
    end
  end
end
