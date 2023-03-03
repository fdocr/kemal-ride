require "kemal"
require "kemal-ride"
require "jennifer"
require "jennifer/adapter/postgres"

Jennifer::Config.configure do |conf|
  conf.from_uri(ENV["DATABASE_URL"]) if ENV.has_key?("DATABASE_URL")
  conf.logger.level = Kemal::Ride.log_level
  conf.adapter = "postgres"
  conf.pool_size = (ENV["DB_POOL"] ||= "5").to_i
end
