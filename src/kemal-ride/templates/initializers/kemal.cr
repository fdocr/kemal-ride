require "kemal-csrf"
require "kemal-session"
require "kemal-session-redis"

add_handler CSRF.new

Kemal::Session.config do |config|
  config.cookie_name = "whack_session"
  config.secret = ENV["SECRET_KEY"]? || "secret_key"
  config.engine = Kemal::Session::RedisEngine.new
end

# Require other initializers
require "./database"
require "./logger"
require "./mailer"
require "./mosquito"
require "./open_telemetry"