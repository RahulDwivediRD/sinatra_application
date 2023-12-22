module ApiHelper
  def authenticated_header(request, user)
    token = JWT.jwt_encode(user.id)
    request.env['HTTP_TOKEN'].merge!(token: token.to_s)
  end
end
