require "jwt"
module JsonWebToken
  extend ActiveSupport::Concern

  def jwt_encode(user, exp = 7.days.from_now)
    payload = { user_id: user.id, exp: exp.to_i } 
    JWT.encode(payload, 'your_secret_key', 'HS256')
  end

  def jwt_decode(token)
    decoded = JWT.decode(token, 'your_secret_key')[0]
    HashWithIndifferentAccess.new decoded
  end

  def authenticate_request
    header = request.env['HTTP_TOKEN']
    header = header.split(' ').last if header

    @current_user = User.find_by(id: decoded_user_id(header))
    render json: { message: 'Invalid Token' } unless @current_user
  rescue JWT::DecodeError => e
    render json: { message: "Invalid Token: #{e.message}" }
  rescue ActiveRecord::RecordNotFound
    render json: { message: 'User not found' }
  end

  private

  def decoded_user_id(token)
    jwt_decode(token)[:user_id]
  end
end