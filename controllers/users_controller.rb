# controllers/users_controller.rb
require 'json'
require_relative '../models/user'
require_relative '../concern/json_web_token'
require 'rotp'
require 'sinatra/base'
require 'byebug'
require 'securerandom'
require 'rqrcode'
require 'base64'
require 'chunky_png'

class UsersController < Sinatra::Base
  include JsonWebToken

  before ['/disable_2fa_authentication', '/change_password'] do
    authenticate_request
  end

  def initialize(app = nil)
    super(app)
    @settings = app.settings if app
  end

  post '/signup' do
    begin
      params = parse_request
      user = User.new(email: params['email'], password: params['password'])
      user.save!
      send_welcome_email(user.email)
      { status: 'success', message: 'User successfully registered' }.to_json
    rescue StandardError => e
      { status: 'error', message: "Unexpected error: #{e.message}" }.to_json
    end
  end

  post '/login' do
    begin
      params = parse_request
      find_user_by_email(params['email'])
      if @user && @user.authenticate(params['password'])
        response_body = { status: 'success', message: 'Successfully login', token: jwt_encode(@user, (Time.now + 24.hours).to_i) }

        if @user.two_factor_enabled?
          totp = get_otp(@user)
          response_body[:otp] = totp.now if totp.present?
        end
        response_body.to_json
      else
        { status: 'error', message: "Invalid username or password" }.to_json
      end
    rescue StandardError => e
      { status: 'error', message: "Cannot generate OTP, please enable 2FA" }.to_json
    end
  end


  post '/enable_2fa_authentication' do
    begin
      params = parse_request
      find_user_by_email(params['email'])
      return { status: 'error', message: 'User not found' }.to_json if @user.nil?

      @user.update!(
        otp_secret: ROTP::Base32.random_base32,
        two_factor_enabled: true
      )
      qr_code_content = "otpauth://totp/#{params['email']}?secret=#{@user.otp_secret}&issuer=YourApp"
      qr_code = RQRCode::QRCode.new(qr_code_content)
      parse_qr_code(qr_code)
      content_type 'image/png'
      @png_image.save('qrcode.png')
      send_file 'qrcode.png'
    rescue StandardError => e
      { status: 'error', message: "Unexpected error: #{e.message}" }.to_json
    end
  end

  post '/verify_auth_otp' do
    begin
      request.body.rewind
      params = parse_request
      user_id = jwt_decode(request.env['HTTP_TOKEN'])['user_id']
      user = User.find(user_id)
      totp = get_otp(user)
      if totp.now == params['otp']
        { status: 'success', message: 'OTP verification successful', token: jwt_encode(user, (Time.now + 24.hours).to_i) }.to_json
      else
        { status: 'error', message: 'Invalid OTP' }.to_json
      end
    rescue StandardError => e
      { status: 'error', message: "Unexpected error: #{e.message}" }.to_json
    end
  end

  private

  def send_welcome_email(email)
    options = @settings.email_options.merge(to: email, subject: 'Welcome to App', body: 'Congratulation! You have sucessfully sing up')
    Pony.mail(options)
  end

  def parse_qr_code(qr_code)
    @png_image = qr_code.as_png(
        bit_depth: 1,
        border_modules: 4,
        color_mode: ChunkyPNG::COLOR_GRAYSCALE,
        color: "black",
        fill: "white",
        module_px_size: 6,
        resize_exactly_to: false,
        resize_gte_to: false,
        size: 500
    )
  end

  def get_otp(user)
    ROTP::TOTP.new(user&.otp_secret, issuer: "My Service")
  end

  def find_user_by_email(email)
    @user = User.find_by!(email: email)
  rescue ActiveRecord::RecordNotFound
    { message: 'User not found.' }.to_json
  end

  def parse_request
    JSON.parse(request.body.read)
  end
end