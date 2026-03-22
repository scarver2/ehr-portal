# frozen_string_literal: true

class GraphqlController < ActionController::API
  include ActionController::Cookies

  # GraphQL supports both:
  # - Portal users: JWT tokens in Authorization header (Rodauth)
  # - Admin users: Session cookies (Devise)

  protect_from_forgery with: :null_session

  before_action :authenticate_graphql_user!

  def execute
    variables = prepare_variables(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]
    context = {
      current_user: current_user
    }
    result = EhrApiSchema.execute(query, variables: variables, context: context, operation_name: operation_name)
    render json: result
  rescue StandardError => e
    raise e unless Rails.env.development?
    handle_error_in_development(e)
  end

  private

  def authenticate_graphql_user!
    # Allow unauthenticated requests; individual resolvers can check current_user
    # This lets GraphQL schema decide what requires authentication
  end

  def current_user
    @current_user ||= load_user_from_jwt_token || load_admin_from_session
  end

  def load_user_from_jwt_token
    token = extract_token_from_request
    return nil unless token

    begin
      secret = Rails.application.credentials.secret_key_base
      payload = JWT.decode(token, secret, true, { algorithm: "HS256" }).first
      user_id = payload["sub"]&.to_i
      user = User.find_by(id: user_id)
      user if user && user.account&.status == "verified"
    rescue JWT::DecodeError, JWT::ExpiredSignature
      nil
    end
  end

  def load_admin_from_session
    # Support Devise session auth for admin users
    current_admin_user if defined?(current_admin_user)
  end

  def extract_token_from_request
    auth_header = request.headers["Authorization"]
    auth_header&.sub(/\ABearer\s+/, "")
  end

  # Handle variables in form data, JSON body, or a blank value
  def prepare_variables(variables_param)
    case variables_param
    when String
      if variables_param.present?
        JSON.parse(variables_param) || {}
      else
        {}
      end
    when Hash
      variables_param
    when ActionController::Parameters
      variables_param.to_unsafe_hash # GraphQL-Ruby will validate name and type of incoming variables.
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{variables_param}"
    end
  end

  def handle_error_in_development(e)
    logger.error e.message
    logger.error e.backtrace.join("\n")

    render json: { errors: [{ message: e.message, backtrace: e.backtrace }], data: {} }, status: 500
  end
end
