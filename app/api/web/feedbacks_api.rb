module API
  class Web::FeedbacksAPI < Grape::API
    resource :feedback do
      desc 'Create feedback'
      params do
        requires :content, type: String
        requires :post_id, type: Integer
      end
      post do
        authenticate_user!
        Feedback.create!({
          content: params[:content],
          user_id: current_user.id,
          post_id: params[:post_id]
        })
      end

      desc 'Get feedback'
      get do
        Feedback.all
      end

      desc 'Delete feedback'
      params do
        requires :id, type: Integer
        requires :user_id, type: Integer
      end
      delete ':id' do
        Feedback.find_by(id: params[:id], user_id: params[:user_id]).destroy
      end

      desc 'Update feedback'
      params do
        requires :id, type: Integer
        requires :content, type: String
        requires :user_id, type: Integer
      end

      put ':id' do
        feedback = Feedback.find_by(id: params[:id], user_id: params[:user_id])
        feedback.update!({
          content: params[:content],
          user_id: params[:user_id]
        })
      end
    end
  end
end
