class CreateUsers < Jennifer::Migration::Base
  def up
    create_table :users do |t|
      t.string :name, { :null => false }
      t.string :email, { :null => false }
      t.string :password_digest, { :null => false }

      ## Recoverable
      # t.string :reset_password_token
      # t.timestamp :reset_password_sent_at

      ## Trackable
      # t.integer :sign_in_count, { :default => 0, :null => false }
      # t.timestamp :current_sign_in_at
      # t.timestamp :last_sign_in_at
      # t.string :current_sign_in_ip
      # t.string :last_sign_in_ip

      ## Lockable
      # t.integer :failed_attempts, { :default => 0, :null => false }
      # t.string :unlock_token
      # t.timestamp :locked_at

      # Confirmable
      # t.string :confirmation_token
      # t.timestamp :confirmed_at
      # t.timestamp :confirmation_sent_at
      # t.string :unconfirmed_email

      # Indexes
      t.index :email, type: :unique

      t.timestamps
    end
  end

  def down
    drop_table :users if table_exists? :users
  end
end
