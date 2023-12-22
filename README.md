### Two-Factor Authentication Service

Two-Factor Authentication Service is a simple sinatra application that is use to authenticate the user using any authenticator application. This README will guide you through setting up the application and adding a new feature to the application.

### Prerequisites

- Ruby 3.1 
- Sinatra 3.1.0
- Postman
- Postgres
- rspec

### Setup

  1. Clone your repository:

  ``

  2. Change into the app directory:

  `$ cd `

  3. Install the required gems:

  `$ bundle install`

  4. Create the database from postgres shell: 

  `$ sudo -u postgres psql`

  `$ CREATE DATABASE your_database_name;`

  `$ \q`

  5. Migrate the database:

  `$ rake db:migrate`

  6. Create a .env file in root directory then you have to change the values in env file:

  7. Start the sinatra server using ruby app.rb


### Task: Development of Two-Factor Authentication Service

- Your task is to develop a two-factor authentication service that provides an additional layer of security for users. The service should include registration, login with two-factor authentication, and account settings management.

### Requirements

1. Registration:

Users should be able to create a new account by providing their email and password.
Passwords should be encrypted and stored securely.
After successful registration, a confirmation email should be sent to the provided email address.

2. Login:

  After registration, users should be able to log in by providing their email and password.
  Two-factor authentication should be implemented using one-time codes (e.g., through SMS, authenticator app, or email).
  Users should enter the correct one-time code to successfully log in.

3. Account Settings Management:

  3.1 Users should be able to change their passwords.
  
  3.2 Users should be able to enable or disable two-factor authentication.
  
  3.3 When enabling two-factor authentication, users should be provided with a secret key (e.g., a QR code) to set up their authenticator app.

4. Error Handling and Security:

  4.1 Handle possible errors during registration, login, and account settings management, providing informative error messages.

  4.2 Follow secure practices and standards when storing and handling passwords and secret keys.
