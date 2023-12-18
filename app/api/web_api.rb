class WebAPI < Grape::API
  format :json
  prefix 'web'

  helpers ::Helpers::AuthenticationHelper

  mount Web::FeedbacksAPI
  mount Web::PostsAPI
  mount Web::SessionsAPI
  mount Web::RegistrationsAPI

  add_swagger_documentation(
    format: :json,
    hide_documentation_path: true,
    mount_path: '/doc',
    hide_format: true,
    doc_version: nil,
    produces: ['application/json'],
    consumes: ['application/json'],
    info: {
      title: 'CodeLearn APIs Documentation',
      description: 'This is a documentation of CodeLearn APIs. To support client rendering the UI',
    }
  )
end
