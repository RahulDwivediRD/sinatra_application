require 'sinatra'
require 'sinatra/activerecord'
require 'pony'
require_relative './controllers/users_controller'
require 'dotenv/load'
require 'puma'

set :port, 4567 

configure do
  enable :sessions
  set :database, { 
    adapter: 'postgresql', 
    database: 'sinatra_test_job', 
    username: ENV['POSTGRES_USERNAME'], 
    password: ENV['POSTGRES_PASSWORD'], 
    host: 'localhost',  
    port: 5432
  }
end

class App < Sinatra::Base
  use UsersController

  configure do
    set :email_options, {
      from: ENV['EMAIL_FROM'],
      via: :smtp,
      via_options: {
        address: ENV['SMTP_ADDRESS'],
        port: '587',
        enable_starttls_auto: true,
        user_name: ENV['SMTP_USERNAME'],
        password: ENV['SMTP_PASSWORD'],
        authentication: 'plain'
      }
    }
  end
  run! if app_file == $0
end