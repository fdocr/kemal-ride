#! /usr/bin/env crystal
#
# Runs both the server and worker executables as separate processes to avoid
# independent deployments. Motivation is for development environments but can
# also save costs in cloud hosting for small projects. For better control over
# a production deployment use the best practices recommended for your hosting
# platform (i.e. run web/worker in separate nodes)

class Bundle
  COMMANDS = ["./app", "./worker"]

  def self.run
    # cleanup processes pre-starting up
    cleanup
    # Run commands in background
    COMMANDS.each { |command| system "#{command} &" }
  end

  def self.cleanup
    system "ps -eaf > ps.log"
    File.each_line("ps.log") do |line|
      results = line.split(" ", remove_empty: true)
      system "kill -9 #{results[1]}" if COMMANDS.find { |command| command == results.last }
    end

    File.delete("ps.log") if File.exists?("ps.log")
  end
end

Bundle.run

# Cleanup before exit
Signal::INT.trap do
  Bundle.cleanup
  puts "Bye 👋🏼"
  exit
end

sleep