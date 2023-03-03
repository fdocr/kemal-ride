require "kemal-csrf"
require "kemal-session"
# require "kemal-session-redis"

add_handler CSRF.new

Kemal::Session.config do |config|
  config.cookie_name = "whack_session"
  config.secret = ENV["SECRET_KEY"]? || "secret_key"
  # config.engine = 
  #   if ENV["REDIS_URL"]?
  #     Kemal::Session::RedisEngine.new(host: "localhost", port: 6379)
  #   else
  #     Kemal::Session::RedisEngine.new(host: "localhost", port: 6379)
  #   end
end