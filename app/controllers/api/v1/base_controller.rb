module Api::V1
  class BaseController < ActionController::API
    include ::ActionController::HttpAuthentication::Token::ControllerMethods

    protected

    def render_json_with_success(status:, data: nil)
      return head(:no_content) if status == :no_content

      json = {status: :success}

      case data
      when ::Hash then json[:type] = :object
      when ::Array then json[:type] = :collection
      end

      json[:data] = data if data

      render status:, json:
    end

    def render_json_with_error(status:, message:, details: {})
      render status:, json: {status: :error, message:, details:}
    end
  end
end
