#! /usr/bin/env crystal
#
# Runs both the server and worker executables in separate fibers to avoid
# independent deployments. Motivation is saving costs in cloud hosting.
# For better control over a production deployment use the best practices
# recommended for your hosting platform (i.e. run web/worker in separate nodes)
#

channel = Channel(Nil).new

spawns = ["./app -p 8080", "./worker"].map do |command|
  spawn do
    res = system command
    channel.send(nil) unless res
  end
end

channel.receive