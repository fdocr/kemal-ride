require "kemal"

module Kemal::Ride
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