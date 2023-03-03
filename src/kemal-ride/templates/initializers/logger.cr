Kemal.config.logger = Kemal::Ride::AppLogHandler.new

# Configure Log levels
Log.setup do |c|
  backend = Log::IOBackend.new

  c.bind("*", Kemal::Ride.log_level, backend)
  c.bind("mosquito.*", Kemal::Ride.log_level, backend)
  c.bind("db", Kemal::Ride.log_level, Log::IOBackend.new(formatter: Jennifer::Adapter::DBFormatter))
end