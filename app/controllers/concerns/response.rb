module Response
  def json_response(messages, is_success, data, status)
    render json: {
      messages:,
      is_success:,
      data:
    }, status:
  end
end
