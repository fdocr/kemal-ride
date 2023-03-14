require "jennifer/model/authentication"

class User < Jennifer::Model::Base
  include Jennifer::Model::Authentication

  with_authentication
  with_timestamps

  mapping(
    id: Primary64,
    name: String,
    email: String?,
    password_digest: { type: String, default: "" },
    password: Password,
    password_confirmation: { type: String?, virtual: true },
    created_at: Time?,
    updated_at: Time?,
  )

  validates_uniqueness :email
  validates_length :password, minimum: 6

  def self.build_empty
    User.build(name: "", password: "")
  end

  def self.build_from(params)
    User.build(
      name: params["name"].as(String),
      email: params["email"].as(String),
      password: params["password"].as(String),
      password_confirmation: params["password"].as(String),
    )
  end
end
