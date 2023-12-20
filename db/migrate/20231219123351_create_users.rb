class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :email
      t.string :password_digest
      t.string :otp_secret
      t.boolean :two_factor_enabled, default: false
      t.timestamps
    end
  end
end
