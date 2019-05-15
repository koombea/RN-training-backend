# frozen_string_literal: true

class DeviseCreateMembers < ActiveRecord::Migration[5.2]
  def change
    create_table :members do |t|
      ## Database authenticatable
      t.string :name,               null: false, default: ""
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at


      t.timestamps null: false
    end

    add_index :members, :email,                unique: true
    add_index :members, :reset_password_token, unique: true
  end
end
