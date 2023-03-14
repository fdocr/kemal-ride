require "kemal"

module Kemal::Ride
  # Class that allows for `HTTP::LogHandler` formatted Kemal logs. Use
  # `Kemal.config.logger = Kemal::Ride::AppLogHandler.new` on your logger
  # initializer to use it.
  class AppLogHandler < Kemal::BaseLogHandler
    def initialize
      @handler = HTTP::LogHandler.new
    end

    def call(context : HTTP::Server::Context)
      @handler.next = @next
      @handler.call(context)
    end

    def write(message : String)
      Log.info { message.strip }
    end
  end
end